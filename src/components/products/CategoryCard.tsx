import { Link } from 'react-router-dom';

interface CategoryCardProps {
  category: {
    id: string;
    name: string;
    description: string | null;
    image_url: string | null;
  };
}

export default function CategoryCard({ category }: CategoryCardProps) {
  return (
    <Link
      to={`/products?category=${encodeURIComponent(category.name)}`}
      className="group relative block overflow-hidden rounded-xl aspect-[4/3]"
    >
      <img
        src={category.image_url || '/placeholder.svg'}
        alt={category.name}
        className="h-full w-full object-cover transition-transform duration-500 group-hover:scale-110"
      />
      <div className="absolute inset-0 bg-gradient-to-t from-foreground/70 via-foreground/20 to-transparent" />
      <div className="absolute inset-x-0 bottom-0 p-4 md:p-6">
        <h3 className="text-lg md:text-xl font-bold text-background mb-1">{category.name}</h3>
        <p className="text-xs md:text-sm text-background/80 line-clamp-2">{category.description}</p>
      </div>
    </Link>
  );
}
