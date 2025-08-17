import { NextResponse } from 'next/server';
import { getServerSession } from 'next-auth';
import { authOptions } from '@/lib/auth';
import { prisma } from '@/lib/prisma';

export async function POST(_req: Request, { params }: { params: { id: string } }) {
  const session = await getServerSession(authOptions);
  if (!session?.user?.email) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  const me = await prisma.user.findUnique({ where: { email: session.user.email } });
  const membership = await prisma.membership.findUnique({ where: { id: params.id } });
  if (!me || !membership) return NextResponse.json({ error: 'Not found' }, { status: 404 });

  const leaderMembership = await prisma.membership.findFirst({ where: { userId: me.id, clubId: membership.clubId, role: 'LEADER' } });
  if (!leaderMembership) return NextResponse.json({ error: 'Forbidden' }, { status: 403 });

  await prisma.membership.update({ where: { id: membership.id }, data: { role: 'STUDENT' } });
  return NextResponse.json({ ok: true });
}