import { NextResponse } from "next/server";
import { ReservationSchema } from "@/lib/schemas";
import { query, pool } from "@/lib/db";
import { PoolClient } from "pg";

export async function POST(request: Request) {

  let client: PoolClient | undefined;

  try {
    client = await pool.connect();

    const body = await request.json();

    const result = ReservationSchema.safeParse(body);

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

    const { userId, coworkingSpaceId } = result.data;

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

    const spaces = await query<{ id: string }>(
        `
        SELECT id
        FROM coworking_spaces
        WHERE id = $1
        `,
        [coworkingSpaceId]
    );

    if (spaces.length === 0) {
      return NextResponse.json(
        {
          error: "Espacio de coworking no encontrado",
        },
        {
          status: 404,
        }
      );
    }

    const { startAt, endAt } = result.data;

    if (new Date(endAt) <= new Date(startAt)) {
        return NextResponse.json(
            {
            error: "La fecha final debe ser mayor que la fecha inicial",
            },
            {
            status: 400,
            }
        );
    }

    const conflicts = await query<{ id: string }>(
        `
        SELECT id
        FROM reservations
        WHERE coworking_space_id = $1
            AND status = 'ACTIVE'
            AND (
            start_at < $3
            AND end_at > $2
            )
        `,
        [
            coworkingSpaceId,
            startAt,
            endAt,
        ]
    );

    if (conflicts.length > 0) {
      return NextResponse.json(
        {
          error: "Conflicto de horario",
        },
        {
          status: 409,
        }
      );
    }

    await client.query("BEGIN");

    const reservationResult = await client.query<{ id: string }>(
        `
        INSERT INTO reservations (
            user_id,
            coworking_space_id,
            start_at,
            end_at
        )
        VALUES (
            $1,
            $2,
            $3,
            $4
        )
        RETURNING id
        `,
        [
            userId,
            coworkingSpaceId,
            startAt,
            endAt,
        ]
    );

    const reservationId = reservationResult.rows[0].id;

    await client.query("COMMIT");

    return NextResponse.json({
        message: "Reserva creada correctamente",
        id: reservationId,
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
