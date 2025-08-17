import { NextResponse } from 'next/server';
import { getServerSession } from 'next-auth';
import { authOptions } from '@/lib/auth';
import { prisma } from '@/lib/prisma';

export async function GET(_req: Request, { params }: { params: { id: string } }) {
  const session = await getServerSession(authOptions);
  if (!session?.user?.email) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  const me = await prisma.user.findUnique({ where: { email: session.user.email } });
  if (!me) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });

  const leader = await prisma.membership.findFirst({ where: { userId: me.id, clubId: params.id, role: 'LEADER' } });
  if (!leader) return NextResponse.json({ error: 'Forbidden' }, { status: 403 });

  const members = await prisma.membership.findMany({ where: { clubId: params.id }, include: { user: true, club: true } });
  const clubName = members[0]?.club.name ?? 'club';
  const rows = [
    ['Name', 'Email', 'Student ID', 'Role'],
    ...members.map((m) => [m.user.name ?? '', m.user.email, m.user.studentId ?? '', m.role]),
  ];
  const csv = rows.map(r => r.map(v => `"${String(v).replace(/"/g, '""')}"`).join(',')).join('\n');
  return new NextResponse(csv, {
    headers: {
      'Content-Type': 'text/csv; charset=utf-8',
      'Content-Disposition': `attachment; filename="${clubName.replace(/[^a-z0-9]+/gi, '-').toLowerCase()}-members.csv"`,
    },
  });
}