import { getServerSession } from 'next-auth';
import { authOptions } from '@/lib/auth';
import { prisma } from '@/lib/prisma';
import { redirect } from 'next/navigation';

export default async function ManageClubPage({ params }: { params: { slug: string } }) {
  const session = await getServerSession(authOptions);
  if (!session?.user?.email) return redirect('/signin');
  const me = await prisma.user.findUnique({ where: { email: session.user.email } });
  if (!me) return redirect('/signin');
  const club = await prisma.club.findUnique({ where: { slug: params.slug } });
  if (!club) return redirect('/clubs');
  const leader = await prisma.membership.findFirst({ where: { userId: me.id, clubId: club.id, role: 'LEADER' } });
  if (!leader) return redirect('/club-leader');

  return (
    <div className="grid gap-6">
      <div>
        <h1 className="text-2xl font-bold">Manage {club.name}</h1>
        <p className="text-gray-600">Update basic info and post announcements.</p>
      </div>
      <form action={`/api/manage/${club.slug}/update`} method="post" className="card p-4 space-y-3">
        <div>
          <label className="block text-sm font-medium mb-1">Description</label>
          <textarea name="description" defaultValue={club.description} className="w-full rounded-md border px-3 py-2" rows={4} />
        </div>
        <div className="grid md:grid-cols-2 gap-3">
          <div>
            <label className="block text-sm font-medium mb-1">Meeting Day</label>
            <input name="meetingDay" defaultValue={club.meetingDay} className="w-full rounded-md border px-3 py-2" />
          </div>
          <div>
            <label className="block text-sm font-medium mb-1">Meeting Time</label>
            <input name="meetingTime" defaultValue={club.meetingTime} className="w-full rounded-md border px-3 py-2" />
          </div>
        </div>
        <div>
          <label className="block text-sm font-medium mb-1">Contact Email</label>
          <input name="contactEmail" defaultValue={club.contactEmail} className="w-full rounded-md border px-3 py-2" />
        </div>
        <button className="btn-primary">Save Changes</button>
      </form>

      <form action={`/api/manage/${club.slug}/announce`} method="post" className="card p-4 space-y-3">
        <h2 className="font-semibold">Post Announcement</h2>
        <div>
          <label className="block text-sm font-medium mb-1">Title</label>
          <input name="title" className="w-full rounded-md border px-3 py-2" />
        </div>
        <div>
          <label className="block text-sm font-medium mb-1">Content</label>
          <textarea name="content" className="w-full rounded-md border px-3 py-2" rows={4} />
        </div>
        <button className="btn-primary">Publish</button>
      </form>
    </div>
  );
}