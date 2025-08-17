import { getServerSession } from 'next-auth';
import { authOptions } from '@/lib/auth';
import { prisma } from '@/lib/prisma';
import Link from 'next/link';

async function getLeaderClub(userEmail: string) {
  const user = await prisma.user.findUnique({ where: { email: userEmail } });
  if (!user) return null;
  const membership = await prisma.membership.findFirst({ where: { userId: user.id, role: 'LEADER' }, include: { club: true } });
  return membership?.club ?? null;
}

export default async function LeaderDashboardPage() {
  const session = await getServerSession(authOptions);
  if (!session?.user?.email) return <div>Please sign in.</div>;
  const club = await getLeaderClub(session.user.email);
  if (!club) return <div>You are not a club leader.</div>;

  const members = await prisma.membership.findMany({ where: { clubId: club.id }, include: { user: true } });
  const applications = await prisma.application.findMany({ where: { clubId: club.id, status: 'PENDING' }, include: { user: true } });

  return (
    <div className="grid gap-6">
      <div>
        <h1 className="text-2xl font-bold">Leader Dashboard</h1>
        <p className="text-gray-600">Manage your club: {club.name}</p>
      </div>
      <section className="card p-4">
        <div className="flex items-center justify-between mb-3">
          <h2 className="font-semibold">Pending Applications</h2>
        </div>
        {applications.length === 0 ? (
          <p className="text-gray-600">No pending applications.</p>
        ) : (
          <div className="overflow-x-auto">
            <table className="min-w-full text-sm">
              <thead>
                <tr className="text-left text-gray-600">
                  <th className="py-2">Name</th>
                  <th className="py-2">Email</th>
                  <th className="py-2">Student ID</th>
                  <th className="py-2">Action</th>
                </tr>
              </thead>
              <tbody>
                {applications.map((a) => (
                  <tr key={a.id} className="border-t">
                    <td className="py-2">{a.user.name ?? '-'}</td>
                    <td className="py-2">{a.user.email}</td>
                    <td className="py-2">{a.user.studentId ?? '-'}</td>
                    <td className="py-2">
                      <div className="flex gap-2">
                        <form action={`/api/leader/applications/${a.id}/approve`} method="post"><button className="btn-primary">Approve</button></form>
                        <form action={`/api/leader/applications/${a.id}/reject`} method="post"><button className="inline-flex items-center rounded-md border border-gray-300 px-3 py-2 text-sm">Reject</button></form>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </section>

      <section className="card p-4">
        <div className="flex items-center justify-between mb-3">
          <h2 className="font-semibold">Members</h2>
          <a className="text-sm text-ashPurple-700 underline" href={`/api/leader/members/${club.id}/export`}>Export CSV</a>
        </div>
        {members.length === 0 ? (
          <p className="text-gray-600">No members yet.</p>
        ) : (
          <div className="overflow-x-auto">
            <table className="min-w-full text-sm">
              <thead>
                <tr className="text-left text-gray-600">
                  <th className="py-2">Name</th>
                  <th className="py-2">Email</th>
                  <th className="py-2">Student ID</th>
                  <th className="py-2">Role</th>
                  <th className="py-2">Actions</th>
                </tr>
              </thead>
              <tbody>
                {members.map((m) => (
                  <tr key={m.id} className="border-t">
                    <td className="py-2">{m.user.name ?? '-'}</td>
                    <td className="py-2">{m.user.email}</td>
                    <td className="py-2">{m.user.studentId ?? '-'}</td>
                    <td className="py-2">{m.role}</td>
                    <td className="py-2">
                      <div className="flex gap-2">
                        <form action={`/api/leader/members/${m.id}/promote`} method="post"><button className="inline-flex items-center rounded-md border border-gray-300 px-3 py-2 text-sm">Make Leader</button></form>
                        <form action={`/api/leader/members/${m.id}/demote`} method="post"><button className="inline-flex items-center rounded-md border border-gray-300 px-3 py-2 text-sm">Make Student</button></form>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </section>

      <div className="flex gap-3">
        <Link href={`/clubs/${club.slug}`} className="btn-primary">View Club Page</Link>
        <Link href={`/manage/${club.slug}`} className="inline-flex items-center rounded-md border border-gray-300 px-3 py-2 text-sm">Edit Club Profile</Link>
      </div>
    </div>
  );
}