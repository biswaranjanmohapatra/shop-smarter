import { useEffect, useState } from 'react';
import { useParams, Link } from 'react-router-dom';
import { Star, Minus, Plus, ArrowLeft } from 'lucide-react';
import { supabase } from '@/integrations/supabase/client';
import Header from '@/components/layout/Header';
import { Button } from '@/components/ui/button';
import { useCart } from '@/contexts/CartContext';
import { useToast } from '@/hooks/use-toast';
import { formatCurrency } from '@/lib/utils';

interface Product {
  id: string;
  name: string;
  description: string | null;
  price: number;
  original_price: number | null;
  image_url: string | null;
  is_featured: boolean | null;
  discount_percent: number | null;
  rating: number | null;
  review_count: number | null;
  stock: number | null;
  category: {
    name: string;
  } | null;
}

export default function ProductDetail() {
  const { id } = useParams();
  const [product, setProduct] = useState<Product | null>(null);
  const [loading, setLoading] = useState(true);
  const [quantity, setQuantity] = useState(1);
  const { addToCart } = useCart();
  const { toast } = useToast();

  useEffect(() => {
    const fetchProduct = async () => {
      if (!id) return;

      const { data, error } = await supabase
        .from('products')
        .select(`
          *,
          category:categories (name)
        `)
        .eq('id', id)
        .maybeSingle();

      if (!error && data) {
        setProduct(data as Product);
      }
      setLoading(false);
    };

    fetchProduct();
  }, [id]);

  const handleAddToCart = async () => {
    if (!product) return;
    await addToCart(product.id, quantity);
    setQuantity(1);
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-background">
        <Header />
        <div className="container py-12">
          <div className="grid md:grid-cols-2 gap-8 lg:gap-12">
            <div className="aspect-square bg-muted rounded-xl animate-pulse" />
            <div className="space-y-4">
              <div className="h-8 bg-muted rounded w-3/4 animate-pulse" />
              <div className="h-6 bg-muted rounded w-1/4 animate-pulse" />
              <div className="h-24 bg-muted rounded animate-pulse" />
            </div>
          </div>
        </div>
      </div>
    );
  }

  if (!product) {
    return (
      <div className="min-h-screen bg-background">
        <Header />
        <div className="container py-12 text-center">
          <p className="text-lg text-muted-foreground">Product not found</p>
          <Link to="/products" className="text-primary hover:underline mt-4 inline-block">
            Back to products
          </Link>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background">
      <Header />

      <main className="py-8 md:py-12">
        <div className="container">
          {/* Back Button */}
          <Link
            to="/products"
            className="inline-flex items-center gap-2 text-sm text-muted-foreground hover:text-foreground mb-6"
          >
            <ArrowLeft className="h-4 w-4" />
            Back to products
          </Link>

          <div className="grid md:grid-cols-2 gap-8 lg:gap-12">
            {/* Image */}
            <div className="relative aspect-square overflow-hidden rounded-xl bg-muted">
              <img
                src={product.image_url || '/placeholder.svg'}
                alt={product.name}
                className="h-full w-full object-cover"
              />
              {product.discount_percent && product.discount_percent > 0 && (
                <span className="absolute top-4 left-4 px-3 py-1 text-xs font-semibold uppercase tracking-wider bg-primary text-primary-foreground rounded">
                  {product.discount_percent}% Off
                </span>
              )}
            </div>

            {/* Details */}
            <div className="flex flex-col">
              {/* Category */}
              {product.category && (
                <p className="text-sm text-muted-foreground mb-2">{product.category.name}</p>
              )}

              {/* Name */}
              <h1 className="text-2xl md:text-3xl font-bold text-foreground mb-4">
                {product.name}
              </h1>

              {/* Rating */}
              {product.rating && product.rating > 0 && (
                <div className="flex items-center gap-2 mb-4">
                  <div className="flex items-center gap-1">
                    <Star className="h-4 w-4 fill-primary text-primary" />
                    <span className="text-sm font-medium">{product.rating}</span>
                  </div>
                  <span className="text-sm text-muted-foreground">
                    ({product.review_count} reviews)
                  </span>
                </div>
              )}

              {/* Price */}
              <div className="flex items-center gap-3 mb-6">
                <span className="text-2xl font-bold text-foreground">
                  {formatCurrency(product.price)}
                </span>
                {product.original_price && product.original_price > product.price && (
                  <span className="text-lg text-muted-foreground line-through">
                    {formatCurrency(product.original_price)}
                  </span>
                )}
              </div>

              {/* Description */}
              {product.description && (
                <p className="text-muted-foreground mb-8 leading-relaxed">
                  {product.description}
                </p>
              )}

              {/* Quantity Selector */}
              <div className="flex items-center gap-4 mb-6">
                <span className="text-sm font-medium text-foreground">Quantity:</span>
                <div className="flex items-center border border-border rounded-lg">
                  <Button
                    variant="ghost"
                    size="icon"
                    className="h-10 w-10"
                    onClick={() => setQuantity(Math.max(1, quantity - 1))}
                  >
                    <Minus className="h-4 w-4" />
                  </Button>
                  <span className="w-12 text-center font-medium">{quantity}</span>
                  <Button
                    variant="ghost"
                    size="icon"
                    className="h-10 w-10"
                    onClick={() => setQuantity(quantity + 1)}
                  >
                    <Plus className="h-4 w-4" />
                  </Button>
                </div>
              </div>

              {/* Add to Cart Button */}
              <Button
                size="lg"
                className="w-full md:w-auto"
                onClick={handleAddToCart}
              >
                Add to Cart - {formatCurrency(product.price * quantity)}
              </Button>

              {/* Stock Info */}
              {product.stock !== null && (
                <p className="text-sm text-muted-foreground mt-4">
                  {product.stock > 0 ? `${product.stock} in stock` : 'Out of stock'}
                </p>
              )}
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}
