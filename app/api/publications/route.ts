import { NextRequest, NextResponse } from "next/server";

import { query } from "@/lib/db";

export async function GET(req: NextRequest) {

  const searchParams = req.nextUrl.searchParams;

  const type = searchParams.get("type");

  let sql = `
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
  `;

  const params: unknown[] = [];

  if (type) {
    params.push(
      type === "libro"
        ? "BOOK"
        : "MAGAZINE"
    );

    sql += ` WHERE p.publication_type = $1`;
  }

  sql += ` ORDER BY p.created_at DESC`;

  const rows = await query(sql, params);

  return NextResponse.json({
    data: rows,
  });

}
