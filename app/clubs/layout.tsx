import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Clubs • Amnuaysilpa Extracurricular Hub',
  description: 'Browse student clubs by day and category',
};

export default function ClubsLayout({ children }: { children: React.ReactNode }) {
  return children;
}