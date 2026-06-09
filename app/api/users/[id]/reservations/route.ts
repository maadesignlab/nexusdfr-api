import { NextResponse } from "next/server";
import { query } from "@/lib/db";

type Reservation = {
  id: string;
  nombre: string;
  tipo: string | null;
  ubicacion: string | null;
  inicio: string;
  fin: string;
  estado: string;
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

    const reservations = await query<Reservation>(
      `
      SELECT
        r.id,

        cs.name AS nombre,
        cs.space_type AS tipo,
        cs.location AS ubicacion,

        r.start_at AS inicio,
        r.end_at AS fin,

        r.status AS estado

      FROM reservations r

      JOIN coworking_spaces cs
        ON cs.id = r.coworking_space_id

      WHERE r.user_id = $1

      ORDER BY r.start_at DESC
      `,
      [id]
    );

    return NextResponse.json(reservations);

  } catch (error) {
    console.error(error);

    return NextResponse.json(
      {
        error: "Error obteniendo reservas",
      },
      {
        status: 500,
      }
    );
  }
}