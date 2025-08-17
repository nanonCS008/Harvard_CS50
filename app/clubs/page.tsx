import { prisma } from '@/lib/prisma';
import Link from 'next/link';

const DAYS = ['Monday','Tuesday','Wednesday','Thursday','Friday'];

export default async function ClubsPage({ searchParams }: { searchParams?: { day?: string; category?: string } }) {
  const day = searchParams?.day;
  const category = searchParams?.category;
  const where: any = {};
  if (day) where.meetingDay = day;
  if (category) where.category = category;

  const clubs = await prisma.club.findMany({ where, orderBy: { name: 'asc' } });
  const categories = Array.from(new Set((await prisma.club.findMany({ select: { category: true } })).map(c => c.category)));

  return (
    <div className="grid gap-6">
      <div className="flex flex-col md:flex-row md:items-end md:justify-between gap-3">
        <div>
          <h1 className="text-2xl font-bold">Browse Clubs</h1>
          <p className="text-gray-600">Find clubs by meeting day and category.</p>
        </div>
        <form className="flex gap-2">
          <select name="day" defaultValue={day ?? ''} className="rounded-md border px-3 py-2">
            <option value="">All days</option>
            {DAYS.map(d => <option key={d} value={d}>{d}</option>)}
          </select>
          <select name="category" defaultValue={category ?? ''} className="rounded-md border px-3 py-2">
            <option value="">All categories</option>
            {categories.map(c => <option key={c} value={c}>{c}</option>)}
          </select>
          <button className="btn-primary">Filter</button>
        </form>
      </div>

      <div className="grid md:grid-cols-2 gap-4">
        {clubs.map((club) => (
          <Link key={club.id} href={`/clubs/${club.slug}`} className="card p-4">
            <div className="flex items-center justify-between">
              <div>
                <h3 className="font-semibold">{club.name}</h3>
                <p className="text-sm text-gray-600">{club.meetingDay} • {club.meetingTime}</p>
              </div>
              <span className="badge">{club.category}</span>
            </div>
            <p className="text-gray-700 mt-2 line-clamp-2">{club.description}</p>
          </Link>
        ))}
      </div>
    </div>
  );
}