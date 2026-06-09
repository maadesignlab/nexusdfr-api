import { NextResponse } from "next/server";
import { query } from "@/lib/db";

type FeaturedPublication = {
  id: string;
  titulo: string;
  autor: string;
  imagen: string | null;
  categoria: string;
  tipo: string;
  precio: number;
};

export async function GET() {
  try {
    const rows = await query<FeaturedPublication>(
      `
      SELECT
        p.id,
        p.title AS titulo,
        a.name AS autor,
        p.cover_url AS imagen,
        c.name AS categoria,

        CASE
          WHEN p.publication_type = 'BOOK'
          THEN 'libro'
          ELSE 'revista'
        END AS tipo,

        p.price AS precio

      FROM publications p

      JOIN categories c
        ON c.id = p.category_id

      JOIN publication_authors pa
        ON pa.publication_id = p.id

      JOIN authors a
        ON a.id = pa.author_id

      WHERE p.featured = TRUE

      ORDER BY p.title
      `
    );

    return NextResponse.json(rows);

  } catch (error) {
    console.error(error);

    return NextResponse.json(
      {
        error: "Error obteniendo publicaciones destacadas",
      },
      {
        status: 500,
      }
    );
  }
}