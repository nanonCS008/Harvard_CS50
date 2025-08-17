import { getServerSession } from 'next-auth';
import { authOptions } from '@/lib/auth';
import { prisma } from '@/lib/prisma';
import Link from 'next/link';

export default async function DashboardPage() {
  const session = await getServerSession(authOptions);
  if (!session?.user?.email) {
    return (
      <div>
        <h1 className="text-2xl font-bold">Dashboard</h1>
        <p className="mt-2 text-gray-600">Please sign in to view your dashboard.</p>
      </div>
    );
  }

  const user = await prisma.user.findUnique({
    where: { email: session.user.email },
    include: {
      memberships: { include: { club: true } },
    },
  });

  const memberships = user?.memberships ?? [];

  const announcements = await prisma.announcement.findMany({
    where: { clubId: { in: memberships.map((m) => m.club.id) } },
    orderBy: { createdAt: 'desc' },
    take: 10,
    include: { club: true },
  }) as Array<{ id: string; title: string; content: string; createdAt: Date; club: { name: string } }>;

  return (
    <div className="grid gap-8">
      <div>
        <h1 className="text-2xl font-bold">Welcome{user?.name ? `, ${user?.name}` : ''}</h1>
        <p className="text-gray-600">Here are your clubs and recent announcements.</p>
      </div>

      <section>
        <h2 className="text-lg font-semibold mb-3">My Clubs</h2>
        {memberships.length === 0 ? (
          <p className="text-gray-600">You haven't joined any clubs yet. <Link href="/clubs" className="text-ashPurple-700 underline">Browse clubs</Link></p>
        ) : (
          <div className="grid md:grid-cols-2 gap-4">
            {memberships.map((m) => (
              <Link key={m.id} href={`/clubs/${m.club.slug}`} className="card p-4">
                <div className="flex items-center justify-between">
                  <div>
                    <h3 className="font-semibold">{m.club.name}</h3>
                    <p className="text-sm text-gray-600">{m.club.meetingDay} • {m.club.meetingTime}</p>
                  </div>
                  <div className="text-right">
                    <span className="badge">{m.club.category}</span>
                    <div className="text-xs text-gray-600 mt-1">Role: {m.role}</div>
                  </div>
                </div>
              </Link>
            ))}
          </div>
        )}
      </section>

      <section>
        <h2 className="text-lg font-semibold mb-3">Upcoming Meetings</h2>
        {memberships.length === 0 ? (
          <p className="text-gray-600">No meetings scheduled.</p>
        ) : (
          <ul className="list-disc pl-6 text-sm text-gray-700">
            {memberships.map((m) => (
              <li key={m.id}>{m.club.name}: {m.club.meetingDay} • {m.club.meetingTime}</li>
            ))}
          </ul>
        )}
      </section>

      <section>
        <h2 className="text-lg font-semibold mb-3">Announcements</h2>
        {announcements.length === 0 ? (
          <p className="text-gray-600">No announcements yet.</p>
        ) : (
          <div className="space-y-3">
            {announcements.map((a) => (
              <div key={a.id} className="card p-4">
                <div className="flex items-center justify-between">
                  <h3 className="font-semibold">{a.title}</h3>
                  <span className="text-xs text-gray-500">{new Date(a.createdAt).toLocaleDateString()}</span>
                </div>
                <p className="text-gray-700 mt-1">{a.content}</p>
                <p className="text-xs text-gray-500 mt-2">From {a.club.name}</p>
              </div>
            ))}
          </div>
        )}
      </section>
    </div>
  );
}