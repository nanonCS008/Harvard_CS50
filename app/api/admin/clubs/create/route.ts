import { NextResponse } from 'next/server';
import { getServerSession } from 'next-auth';
import { authOptions } from '@/lib/auth';
import { prisma } from '@/lib/prisma';

export async function POST(req: Request) {
  const session = await getServerSession(authOptions);
  if (!session?.user?.email) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  const me = await prisma.user.findUnique({ where: { email: session.user.email } });
  if (me?.role !== 'ADMIN' && me?.role !== 'TEACHER') return NextResponse.json({ error: 'Forbidden' }, { status: 403 });

  const { name, slug, description, category, meetingDay, meetingTime, contactEmail, advisor, imageUrl } = await req.json();
  if (!name || !slug || !description || !category || !meetingDay || !meetingTime || !contactEmail) {
    return NextResponse.json({ error: 'Missing fields' }, { status: 400 });
  }
  const club = await prisma.club.create({ data: { name, slug, description, category, meetingDay, meetingTime, contactEmail, advisor, imageUrl } });
  return NextResponse.json({ id: club.id, slug: club.slug });
}