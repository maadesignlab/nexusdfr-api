import { NextResponse } from "next/server";
import { query } from "@/lib/db";

type Publication = {
  id: string;
  titulo: string;
  autor: string;
  año: number | null;
  sinopsis: string | null;
  imagen: string | null;
  categoria: string;
  tipo: string;
  precio: number;
  inventario: number;
  codigo: string | null;
  editorial: string | null;
  masVendido: boolean;
  paginas: number | null;
};

export async function GET(
  request: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;

    const rows = await query<Publication>(
      `
      SELECT
        p.id,
        p.title AS titulo,
        a.name AS autor,
        p.published_year AS año,
        p.description AS sinopsis,
        p.cover_url AS imagen,
        c.name AS categoria,

        CASE
          WHEN p.publication_type = 'BOOK' THEN 'libro'
          ELSE 'revista'
        END AS tipo,

        p.price AS precio,
        p.stock AS inventario,
        p.isbn AS codigo,
        p.publisher AS editorial,
        p.featured AS "masVendido",
        p.pages AS paginas

      FROM publications p

      JOIN categories c
        ON c.id = p.category_id

      JOIN publication_authors pa
        ON pa.publication_id = p.id

      JOIN authors a
        ON a.id = pa.author_id

      WHERE p.id = $1
      `,
      [id]
    );

    if (rows.length === 0) {
      return NextResponse.json(
        { error: "Publicación no encontrada" },
        { status: 404 }
      );
    }

    return NextResponse.json(rows[0]);

  } catch (error) {
    console.error(error);

    return NextResponse.json(
      { error: "Error obteniendo publicación" },
      { status: 500 }
    );
  }
}