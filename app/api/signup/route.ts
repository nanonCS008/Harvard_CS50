import { NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import bcrypt from 'bcryptjs';

const STUDENT_EMAIL_DOMAIN = '@student.amnuaysilpa.ac.th';

export async function POST(req: Request) {
  const { email, password, name, studentId } = await req.json();
  if (!email || !password) {
    return NextResponse.json({ error: 'Missing email or password' }, { status: 400 });
  }
  const normalized = String(email).toLowerCase();
  if (!normalized.endsWith(STUDENT_EMAIL_DOMAIN)) {
    return NextResponse.json({ error: 'Email must be a student email' }, { status: 400 });
  }
  const existing = await prisma.user.findUnique({ where: { email: normalized } });
  if (existing) {
    return NextResponse.json({ error: 'User already exists' }, { status: 409 });
  }
  const passwordHash = await bcrypt.hash(password, 10);
  const user = await prisma.user.create({ data: { email: normalized, passwordHash, name, studentId } });
  return NextResponse.json({ id: user.id, email: user.email });
}