import { NextResponse } from 'next/server';
import { getServerSession } from 'next-auth';
import { authOptions } from '@/lib/auth';
import { prisma } from '@/lib/prisma';

export async function POST(_req: Request, { params }: { params: { id: string } }) {
  const session = await getServerSession(authOptions);
  if (!session?.user?.email) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  const me = await prisma.user.findUnique({ where: { email: session.user.email } });
  if (!me) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });

  const app = await prisma.application.findUnique({ where: { id: params.id } });
  if (!app) return NextResponse.json({ error: 'Not found' }, { status: 404 });

  const leaderMembership = await prisma.membership.findFirst({ where: { userId: me.id, clubId: app.clubId, role: 'LEADER' } });
  if (!leaderMembership) return NextResponse.json({ error: 'Not a leader of this club' }, { status: 403 });

  await prisma.$transaction([
    prisma.application.update({ where: { id: app.id }, data: { status: 'APPROVED' } }),
    prisma.membership.upsert({
      where: { userId_clubId: { userId: app.userId, clubId: app.clubId } },
      update: { role: 'STUDENT' },
      create: { userId: app.userId, clubId: app.clubId, role: 'STUDENT' },
    }),
  ]);

  return NextResponse.json({ ok: true });
}