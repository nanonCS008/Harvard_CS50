import { prisma } from '@/lib/prisma';
import Image from 'next/image';
import { getServerSession } from 'next-auth';
import { authOptions } from '@/lib/auth';
import Link from 'next/link';

export default async function ClubDetailPage({ params }: { params: { slug: string } }) {
  const session = await getServerSession(authOptions);
  const club = await prisma.club.findUnique({ where: { slug: params.slug } });
  if (!club) return <div>Club not found</div>;

  let hasMembership = false;
  let hasPendingApplication = false;
  if (session?.user?.email) {
    const user = await prisma.user.findUnique({ where: { email: session.user.email } });
    if (user) {
      const membership = await prisma.membership.findUnique({ where: { userId_clubId: { userId: user.id, clubId: club.id } } });
      hasMembership = Boolean(membership);
      const application = await prisma.application.findFirst({ where: { clubId: club.id, userId: user.id, status: 'PENDING' } });
      hasPendingApplication = Boolean(application);
    }
  }

  return (
    <div className="grid gap-6 md:grid-cols-[2fr_1fr]">
      <div className="space-y-4">
        {club.imageUrl && (
          <div className="relative h-64 w-full overflow-hidden rounded-xl border">
            <Image src={club.imageUrl} alt={club.name} fill className="object-cover" />
          </div>
        )}
        <h1 className="text-2xl font-bold">{club.name}</h1>
        <div className="flex flex-wrap gap-2 text-sm text-gray-600">
          <span className="badge">{club.category}</span>
          <span>{club.meetingDay}</span>
          <span>•</span>
          <span>{club.meetingTime}</span>
          {club.advisor && (
            <>
              <span>•</span>
              <span>Advisor: {club.advisor}</span>
            </>
          )}
        </div>
        <p className="text-gray-700 whitespace-pre-wrap">{club.description}</p>
      </div>
      <aside className="space-y-4">
        <div className="card p-4">
          <h2 className="font-semibold mb-2">Contact</h2>
          <p className="text-gray-700 text-sm">{club.contactEmail}</p>
        </div>
        <div className="card p-4">
          <h2 className="font-semibold mb-2">Join this club</h2>
          {!session?.user ? (
            <Link href="/signin" className="btn-primary w-full text-center">Sign in to apply</Link>
          ) : hasMembership ? (
            <p className="text-gray-600 text-sm">You are already a member.</p>
          ) : hasPendingApplication ? (
            <p className="text-gray-600 text-sm">Application pending approval.</p>
          ) : (
            <form action={`/api/clubs/${club.slug}/apply`} method="post">
              <button className="btn-primary w-full">Apply</button>
            </form>
          )}
        </div>
      </aside>
    </div>
  );
}