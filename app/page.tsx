import Link from 'next/link';
import Image from 'next/image';

export default function HomePage() {
  return (
    <div className="grid gap-12 md:grid-cols-2 items-center">
      <div className="space-y-6">
        <h1 className="text-3xl md:text-5xl font-extrabold leading-tight">
          Discover, Join, and Lead clubs at
          <span className="block text-transparent bg-clip-text bg-gradient-to-r from-ashPink-500 via-ashPurple-600 to-ashBlue-600">Amnuaysilpa</span>
        </h1>
        <p className="text-gray-600 text-lg">Browse all student clubs, apply to join, and keep track of your activities in one place.</p>
        <div className="flex gap-3">
          <Link href="/clubs" className="btn-primary" aria-label="Browse Clubs">Browse Clubs</Link>
          <Link href="/signin" className="inline-flex items-center rounded-md border border-gray-300 px-4 py-2 font-medium hover:bg-gray-50">Sign in</Link>
        </div>
      </div>
      <div className="relative h-64 md:h-96">
        <Image src="/hero-illustration.svg" alt="Students collaborating in clubs" fill className="object-contain" priority />
      </div>
    </div>
  );
}