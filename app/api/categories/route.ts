import { NextResponse } from "next/server";
import { query } from "@/lib/db";

type Category = {
  id: string;
  name: string;
  slug: string;
};

export async function GET() {
  try {
    const categories = await query<Category>(`
      SELECT
        id,
        name,
        slug
      FROM categories
      ORDER BY name;
    `);

    return NextResponse.json(categories);
  } catch (error) {
    console.error(error);

    return NextResponse.json(
      {
        error: "Error obteniendo categorías",
      },
      {
        status: 500,
      }
    );
  }
}