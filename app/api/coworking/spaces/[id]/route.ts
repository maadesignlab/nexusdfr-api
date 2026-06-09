import { NextResponse } from "next/server";
import { query } from "@/lib/db";

type CoworkingSpace = {
  id: string;
  nombre: string;
  tipo: string | null;
  capacidad: number;
  ubicacion: string | null;
  ocupado: boolean;
};

export async function GET(
  request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;

    const rows = await query<CoworkingSpace>(
      `
      SELECT
        id,
        name AS nombre,
        space_type AS tipo,
        capacity AS capacidad,
        location AS ubicacion,
        NOT available AS ocupado
      FROM coworking_spaces
      WHERE id = $1
      `,
      [id]
    );

    if (rows.length === 0) {
      return NextResponse.json(
        {
          error: "Espacio no encontrado",
        },
        {
          status: 404,
        }
      );
    }

    return NextResponse.json(rows[0]);

  } catch (error) {
    console.error(error);

    return NextResponse.json(
      {
        error: "Error obteniendo espacio",
      },
      {
        status: 500,
      }
    );
  }
}