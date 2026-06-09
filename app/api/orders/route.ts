import { NextResponse } from "next/server";
import { OrderSchema } from "@/lib/schemas";
import { query, pool } from "@/lib/db";
import { PoolClient } from "pg";

type Publication = {
  id: string;
  title: string;
  price: number;
  stock: number;
};

export async function POST(request: Request) {

  let client: PoolClient | undefined;

  try {
    client = await pool.connect();

    const body = await request.json();

    const result = OrderSchema.safeParse(body);

    if (!result.success) {
      return NextResponse.json(
        {
          error: "Datos inválidos",
          details: result.error.flatten(),
        },
        {
          status: 400,
        }
      );
    }

    const { userId } = result.data;

    const users = await query<{ id: string }>(
      `
      SELECT id
      FROM users
      WHERE id = $1
      `,
      [userId]
    );

    if (users.length === 0) {
      return NextResponse.json(
        {
          error: "Usuario no encontrado",
        },
        {
          status: 404,
        }
      );
    }

    const publications: Publication[] = [];

    for (const item of result.data.items) {
      const rows = await query<Publication>(
        `
        SELECT
          id,
          title,
          price,
          stock
        FROM publications
        WHERE id = $1
        `,
        [item.publicationId]
      );

      if (rows.length === 0) {
        return NextResponse.json(
          {
            error: `Publicación no encontrada: ${item.publicationId}`,
          },
          {
            status: 404,
          }
        );
      }

      const publication = rows[0];

      if (publication.stock < item.quantity) {
        return NextResponse.json(
          {
            error: `Stock insuficiente para ${publication.title}`,
          },
          {
            status: 400,
          }
        );
      }

      publications.push(publication);
    }

    let total = 0;

    for (const item of result.data.items) {
      const publication = publications.find(
        (p) => p.id === item.publicationId
      );

      if (!publication) {
        continue;
      }

      total += Number(publication.price) * item.quantity;
    }

    await client.query("BEGIN");

    const orderResult = await client.query<{ id: string }>(
        `
        INSERT INTO orders (
            user_id,
            total
        )
        VALUES (
            $1,
            $2
        )
        RETURNING id
        `,
        [userId, total]
    );

    const orderId = orderResult.rows[0].id;

    for (const item of result.data.items) {
        const publication = publications.find(
            (p) => p.id === item.publicationId
        );

        if (!publication) {
            continue;
        }

        const subtotal =
            Number(publication.price) * item.quantity;

        await client.query(
            `
            INSERT INTO order_items (
            order_id,
            publication_id,
            quantity,
            unit_price,
            subtotal
            )
            VALUES (
            $1,
            $2,
            $3,
            $4,
            $5
            )
            `,
            [
            orderId,
            publication.id,
            item.quantity,
            publication.price,
            subtotal,
            ]
        );

        await client.query(
            `
            UPDATE publications
            SET
              stock = stock - $1,
              sold = sold + $1
            WHERE id = $2
            `,
            [
                item.quantity,
                publication.id,
            ]
        );
    }

    await client.query("COMMIT");

    return NextResponse.json({
        message: "Orden creada correctamente",
        orderId,
        total,
    });

    } catch (error) {
        if (client) {
                await client.query("ROLLBACK");
            }

            console.error(error);

            return NextResponse.json(
                {
                error: "Error procesando solicitud",
                },
                {
                status: 500,
                }
            );
        }

        finally {
            client?.release();
        }
}