import { NextResponse } from 'next/server';
import { getServerSession } from 'next-auth';
import { authOptions } from '@/lib/auth';
import { prisma } from '@/lib/prisma';

export async function POST(req: Request, { params }: { params: { slug: string } }) {
  const session = await getServerSession(authOptions);
  if (!session?.user?.email) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  const me = await prisma.user.findUnique({ where: { email: session.user.email } });
  const club = await prisma.club.findUnique({ where: { slug: params.slug } });
  if (!me || !club) return NextResponse.json({ error: 'Not found' }, { status: 404 });

  const leader = await prisma.membership.findFirst({ where: { userId: me.id, clubId: club.id, role: 'LEADER' } });
  if (!leader) return NextResponse.json({ error: 'Forbidden' }, { status: 403 });

  const formData = await req.formData();
  const title = String(formData.get('title') ?? '');
  const content = String(formData.get('content') ?? '');
  if (!title || !content) return NextResponse.json({ error: 'Missing fields' }, { status: 400 });

  await prisma.announcement.create({ data: { clubId: club.id, title, content } });
  return NextResponse.redirect(new URL(`/manage/${club.slug}`, req.url));
}