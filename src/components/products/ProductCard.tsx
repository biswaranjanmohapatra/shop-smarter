import { Link } from 'react-router-dom';
import { Star } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { useCart } from '@/contexts/CartContext';

interface ProductCardProps {
  product: {
    id: string;
    name: string;
    price: number;
    original_price: number | null;
    image_url: string | null;
    is_featured: boolean | null;
    discount_percent: number | null;
    rating: number | null;
    review_count: number | null;
  };
}

export default function ProductCard({ product }: ProductCardProps) {
  const { addToCart } = useCart();

  const handleAddToCart = (e: React.MouseEvent) => {
    e.preventDefault();
    addToCart(product.id);
  };

  return (
    <Link
      to={`/products/${product.id}`}
      className="group block"
    >
      <div className="relative aspect-square overflow-hidden rounded-lg bg-muted mb-3">
        <img
          src={product.image_url || '/placeholder.svg'}
          alt={product.name}
          className="h-full w-full object-cover transition-transform duration-500 group-hover:scale-105"
        />
        
        {/* Badges */}
        <div className="absolute top-3 left-3 flex flex-col gap-2">
          {product.is_featured && (
            <span className="px-2 py-1 text-[10px] font-semibold uppercase tracking-wider bg-foreground text-background rounded">
              Featured
            </span>
          )}
          {product.discount_percent && product.discount_percent > 0 && (
            <span className="px-2 py-1 text-[10px] font-semibold uppercase tracking-wider bg-primary text-primary-foreground rounded">
              {product.discount_percent}% Off
            </span>
          )}
        </div>

        {/* Add to Cart Button */}
        <div className="absolute inset-x-3 bottom-3 opacity-0 translate-y-2 group-hover:opacity-100 group-hover:translate-y-0 transition-all duration-300">
          <Button
            onClick={handleAddToCart}
            className="w-full bg-foreground text-background hover:bg-foreground/90"
          >
            Add to Cart
          </Button>
        </div>
      </div>

      {/* Product Info */}
      <div className="space-y-1">
        <h3 className="text-sm font-medium text-foreground line-clamp-1 group-hover:text-primary transition-colors">
          {product.name}
        </h3>
        
        {/* Rating */}
        {product.rating && product.rating > 0 && (
          <div className="flex items-center gap-1">
            <Star className="h-3 w-3 fill-primary text-primary" />
            <span className="text-xs text-muted-foreground">
              {product.rating} ({product.review_count})
            </span>
          </div>
        )}

        {/* Price */}
        <div className="flex items-center gap-2">
          <span className="text-sm font-bold text-foreground">
            ${product.price.toFixed(2)}
          </span>
          {product.original_price && product.original_price > product.price && (
            <span className="text-xs text-muted-foreground line-through">
              ${product.original_price.toFixed(2)}
            </span>
          )}
        </div>
      </div>
    </Link>
  );
}
