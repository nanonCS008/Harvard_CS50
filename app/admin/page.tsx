import { getServerSession } from 'next-auth';
import { authOptions } from '@/lib/auth';
import { prisma } from '@/lib/prisma';

export default async function AdminPage() {
  const session = await getServerSession(authOptions);
  if (!session?.user?.email) return <div>Please sign in.</div>;
  const me = await prisma.user.findUnique({ where: { email: session.user.email } });
  if (me?.role !== 'ADMIN' && me?.role !== 'TEACHER') return <div>Not authorized.</div>;

  const clubs = await prisma.club.findMany({ include: { memberships: { include: { user: true } } } });

  return (
    <div className="grid gap-6">
      <div>
        <h1 className="text-2xl font-bold">Admin Dashboard</h1>
        <p className="text-gray-600">Overview of clubs and leaders.</p>
      </div>

      <div className="space-y-4">
        {clubs.map((club) => {
          const leaders = club.memberships.filter((m) => m.role === 'LEADER');
          const count = club.memberships.length;
          return (
            <div key={club.id} className="card p-4">
              <div className="flex items-start justify-between gap-6">
                <div>
                  <h2 className="font-semibold">{club.name}</h2>
                  <p className="text-sm text-gray-600">{club.category} • {club.meetingDay} {club.meetingTime}</p>
                  <div className="text-sm mt-2">
                    <div className="font-medium">Leaders</div>
                    {leaders.length === 0 ? (
                      <div className="text-gray-600">-</div>
                    ) : (
                      <ul className="list-disc pl-5">
                        {leaders.map((m) => (
                          <li key={m.id}>{m.user.email}</li>
                        ))}
                      </ul>
                    )}
                  </div>
                </div>
                <div className="text-right text-sm">
                  <div className="font-medium">{count} members</div>
                </div>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}