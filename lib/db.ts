import { Pool, type QueryResultRow } from "pg";

declare global {
  var __pgPool: Pool | undefined;
}

export const pool =
  global.__pgPool ??
  new Pool({
    connectionString: process.env.DATABASE_URL,
  });

if (process.env.NODE_ENV !== "production") {
  global.__pgPool = pool;
}

export async function query<T extends QueryResultRow>(
  sql: string,
  params: unknown[] = []
): Promise<T[]> {

  const { rows } = await pool.query<T>(sql, params);

  return rows;

}