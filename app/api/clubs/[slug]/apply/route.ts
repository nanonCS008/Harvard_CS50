import { NextResponse } from 'next/server';
import { getServerSession } from 'next-auth';
import { authOptions } from '@/lib/auth';
import { prisma } from '@/lib/prisma';

export async function POST(_req: Request, { params }: { params: { slug: string } }) {
  const session = await getServerSession(authOptions);
  if (!session?.user?.email) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });

  const club = await prisma.club.findUnique({ where: { slug: params.slug } });
  if (!club) return NextResponse.json({ error: 'Club not found' }, { status: 404 });

  const user = await prisma.user.findUnique({ where: { email: session.user.email } });
  if (!user) return NextResponse.json({ error: 'User not found' }, { status: 404 });

  const membership = await prisma.membership.findUnique({ where: { userId_clubId: { userId: user.id, clubId: club.id } } });
  if (membership) return NextResponse.json({ error: 'Already a member' }, { status: 400 });

  const existing = await prisma.application.findFirst({ where: { clubId: club.id, userId: user.id } });
  if (existing) return NextResponse.json({ error: 'Already applied' }, { status: 400 });

  const app = await prisma.application.create({ data: { clubId: club.id, userId: user.id } });
  return NextResponse.json({ id: app.id, status: app.status });
}