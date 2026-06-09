import { NextResponse } from "next/server";
import { query } from "@/lib/db";

type Purchase = {
  orderId: string;
  fecha: string;
  publicationId: string;
  titulo: string;
  cantidad: number;
  precioUnitario: number;
  subtotal: number;
};

export async function GET(
  request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;

    const users = await query<{ id: string }>(
      `
      SELECT id
      FROM users
      WHERE id = $1
      `,
      [id]
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

    const purchases = await query<Purchase>(
      `
      SELECT
        o.id AS "orderId",
        o.created_at AS fecha,

        p.id AS "publicationId",
        p.title AS titulo,
        p.cover_url AS imagen,
        p.publisher AS editorial,

        oi.quantity AS cantidad,
        oi.unit_price AS "precioUnitario",
        oi.subtotal

      FROM orders o

      INNER JOIN order_items oi
        ON oi.order_id = o.id

      INNER JOIN publications p
        ON p.id = oi.publication_id

      WHERE o.user_id = $1

      ORDER BY o.created_at DESC
      `,
      [id]
    );

    return NextResponse.json(purchases);
  } catch (error) {
    console.error(error);

    return NextResponse.json(
      {
        error: "Error obteniendo compras",
      },
      {
        status: 500,
      }
    );
  }
}