import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
  const password = await bcrypt.hash('Password123!', 10);

  const admin = await prisma.user.upsert({
    where: { email: '62000@student.amnuaysilpa.ac.th' },
    update: { role: 'ADMIN' },
    create: {
      email: '62000@student.amnuaysilpa.ac.th',
      studentId: '62000',
      name: 'Admin User',
      passwordHash: password,
      role: 'ADMIN',
    },
  });

  const leader = await prisma.user.upsert({
    where: { email: '62001@student.amnuaysilpa.ac.th' },
    update: {},
    create: {
      email: '62001@student.amnuaysilpa.ac.th',
      studentId: '62001',
      name: 'Club Leader',
      passwordHash: password,
      role: 'STUDENT',
    },
  });

  const student = await prisma.user.upsert({
    where: { email: '62002@student.amnuaysilpa.ac.th' },
    update: {},
    create: {
      email: '62002@student.amnuaysilpa.ac.th',
      studentId: '62002',
      name: 'Regular Student',
      passwordHash: password,
      role: 'STUDENT',
    },
  });

  const codingClub = await prisma.club.upsert({
    where: { slug: 'coding-club' },
    update: {},
    create: {
      name: 'Coding Club',
      slug: 'coding-club',
      description: 'Learn programming, build projects, and compete in coding challenges.',
      category: 'Academic',
      meetingDay: 'Wednesday',
      meetingTime: '15:30-16:30',
      contactEmail: 'codingclub@amnuaysilpa.ac.th',
      advisor: 'Mr. Somchai',
      imageUrl: '/clubs/coding.svg',
    },
  });

  const serviceClub = await prisma.club.upsert({
    where: { slug: 'service-club' },
    update: {},
    create: {
      name: 'Service Club',
      slug: 'service-club',
      description: 'Organize community service activities and school events.',
      category: 'Service',
      meetingDay: 'Friday',
      meetingTime: '15:30-16:30',
      contactEmail: 'serviceclub@amnuaysilpa.ac.th',
      advisor: 'Ms. Patcharaporn',
      imageUrl: '/clubs/service.svg',
    },
  });

  await prisma.membership.upsert({
    where: { userId_clubId: { userId: leader.id, clubId: codingClub.id } },
    update: { role: 'LEADER' },
    create: { userId: leader.id, clubId: codingClub.id, role: 'LEADER' },
  });

  await prisma.membership.upsert({
    where: { userId_clubId: { userId: student.id, clubId: serviceClub.id } },
    update: {},
    create: { userId: student.id, clubId: serviceClub.id, role: 'STUDENT' },
  });

  console.log('Seed complete. Admin: 62000@student.amnuaysilpa.ac.th / Password123!');
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
}).finally(async () => {
  await prisma.$disconnect();
});