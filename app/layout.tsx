import type { Metadata } from 'next';
import './globals.css';
import Link from 'next/link';
import Image from 'next/image';
import { getServerSession } from 'next-auth';
import { authOptions } from '@/lib/auth';
import { SignOutButton } from '@/components/SignOutButton';

export const metadata: Metadata = {
  title: 'Amnuaysilpa Extracurricular Hub',
  description: 'Clubs, activities, and announcements at Amnuaysilpa',
};

export default async function RootLayout({ children }: { children: React.ReactNode }) {
  const session = await getServerSession(authOptions);
  const user = session?.user;
  return (
    <html lang="en">
      <body>
        <header className="border-b bg-white">
          <nav className="container-responsive flex h-16 items-center justify-between">
            <div className="flex items-center gap-3">
              <Link href="/" className="flex items-center gap-2">
                <Image src="/logo.svg" width={36} height={36} alt="Amnuaysilpa" />
                <span className="font-bold text-lg">Amnuaysilpa Extracurricular Hub</span>
              </Link>
            </div>
            <div className="flex items-center gap-4">
              <Link href="/clubs" className="text-sm font-medium hover:text-ashPurple-600">Clubs</Link>
              {user && (
                <>
                  <Link href="/dashboard" className="text-sm font-medium hover:text-ashPurple-600">My Dashboard</Link>
                  <SignOutButton />
                </>
              )}
              {!user && (
                <Link href="/signin" className="btn-primary text-sm">Sign in</Link>
              )}
            </div>
          </nav>
        </header>
        <main className="container-responsive py-6">{children}</main>
        <footer className="mt-10 border-t py-6 text-center text-sm text-gray-500">
          © {new Date().getFullYear()} Amnuaysilpa School. All rights reserved.
        </footer>
      </body>
    </html>
  );
}