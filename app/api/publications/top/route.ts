import { NextResponse } from "next/server";
import { query } from "@/lib/db";

type TopPublication = {
  id: string;
  titulo: string;
  autor: string;
  imagen: string | null;
  tipo: string;
  vendidos: number;
};

export async function GET() {
  try {
    const rows = await query<TopPublication>(
      `
      SELECT
        p.id,
        p.title AS titulo,
        a.name AS autor,
        p.cover_url AS imagen,

        CASE
          WHEN p.publication_type = 'BOOK'
          THEN 'libro'
          ELSE 'revista'
        END AS tipo,

        p.sold AS vendidos

      FROM publications p

      JOIN publication_authors pa
        ON pa.publication_id = p.id

      JOIN authors a
        ON a.id = pa.author_id

      ORDER BY sold DESC

      LIMIT 10
      `
    );

    return NextResponse.json(rows);

  } catch (error) {
    console.error(error);

    return NextResponse.json(
      {
        error: "Error obteniendo top publicaciones",
      },
      {
        status: 500,
      }
    );
  }
}
