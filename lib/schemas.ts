import { z } from "zod";

export const OrderSchema = z.object({
  userId: z.uuid(),

  items: z.array(
    z.object({
      publicationId: z.uuid(),
      quantity: z.number().int().positive(),
    })
  ).min(1),
});

export const ReservationSchema = z.object({
  userId: z.uuid(),
  coworkingSpaceId: z.uuid(),

  startAt: z.string(),
  endAt: z.string(),
});

export type OrderInput = z.infer<typeof OrderSchema>;
export type ReservationInput = z.infer<typeof ReservationSchema>;

