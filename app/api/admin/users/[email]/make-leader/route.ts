import { NextResponse } from 'next/server';
import { getServerSession } from 'next-auth';
import { authOptions } from '@/lib/auth';
import { prisma } from '@/lib/prisma';

export async function POST(req: Request, { params }: { params: { email: string } }) {
  const session = await getServerSession(authOptions);
  if (!session?.user?.email) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  const me = await prisma.user.findUnique({ where: { email: session.user.email } });
  if (me?.role !== 'ADMIN' && me?.role !== 'TEACHER') return NextResponse.json({ error: 'Forbidden' }, { status: 403 });

  const url = new URL(req.url);
  const clubSlug = url.searchParams.get('clubSlug');
  if (!clubSlug) return NextResponse.json({ error: 'Missing clubSlug' }, { status: 400 });

  const club = await prisma.club.findUnique({ where: { slug: clubSlug } });
  const user = await prisma.user.findUnique({ where: { email: decodeURIComponent(params.email) } });
  if (!club || !user) return NextResponse.json({ error: 'Not found' }, { status: 404 });

  await prisma.membership.upsert({
    where: { userId_clubId: { userId: user.id, clubId: club.id } },
    update: { role: 'LEADER' },
    create: { userId: user.id, clubId: club.id, role: 'LEADER' },
  });

  return NextResponse.json({ ok: true });
}