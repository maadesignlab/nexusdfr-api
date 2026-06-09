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

export async function GET() {
  try {
    const spaces = await query<CoworkingSpace>(`
      SELECT
        id,
        name AS nombre,
        space_type AS tipo,
        capacity AS capacidad,
        location AS ubicacion,

        NOT available AS ocupado

      FROM coworking_spaces

      ORDER BY name;
    `);

    return NextResponse.json(spaces);
  } catch (error) {
    console.error(error);

    return NextResponse.json(
      {
        error: "Error obteniendo espacios",
      },
      {
        status: 500,
      }
    );
  }
}