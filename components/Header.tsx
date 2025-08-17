import Link from 'next/link';
import Image from 'next/image';

export function Header() {
  return (
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
          <Link href="/signin" className="btn-primary text-sm">Sign in</Link>
        </div>
      </nav>
    </header>
  );
}