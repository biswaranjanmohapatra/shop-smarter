-- Create profiles table for user data
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL UNIQUE,
  full_name TEXT,
  email TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

-- Enable RLS on profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Users can view their own profile" ON public.profiles FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update their own profile" ON public.profiles FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own profile" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Create trigger for new user profiles
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (user_id, full_name, email)
  VALUES (new.id, new.raw_user_meta_data ->> 'full_name', new.email);
  RETURN new;
END;
$$;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Create categories table
CREATE TABLE public.categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

-- Enable RLS and allow public read
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Categories are publicly readable" ON public.categories FOR SELECT USING (true);

-- Create products table
CREATE TABLE public.products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  price DECIMAL(10,2) NOT NULL,
  original_price DECIMAL(10,2),
  image_url TEXT,
  category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
  is_featured BOOLEAN DEFAULT false,
  is_new_arrival BOOLEAN DEFAULT false,
  discount_percent INTEGER DEFAULT 0,
  rating DECIMAL(2,1) DEFAULT 0,
  review_count INTEGER DEFAULT 0,
  stock INTEGER DEFAULT 100,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

-- Enable RLS and allow public read
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Products are publicly readable" ON public.products FOR SELECT USING (true);

-- Create cart_items table
CREATE TABLE public.cart_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  product_id UUID REFERENCES public.products(id) ON DELETE CASCADE NOT NULL,
  quantity INTEGER NOT NULL DEFAULT 1,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  UNIQUE(user_id, product_id)
);

-- Enable RLS on cart_items
ALTER TABLE public.cart_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their own cart" ON public.cart_items FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can add to their own cart" ON public.cart_items FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own cart" ON public.cart_items FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete from their own cart" ON public.cart_items FOR DELETE USING (auth.uid() = user_id);

-- Create orders table
CREATE TABLE public.orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending',
  subtotal DECIMAL(10,2) NOT NULL,
  shipping DECIMAL(10,2) DEFAULT 0,
  total DECIMAL(10,2) NOT NULL,
  shipping_address TEXT NOT NULL,
  city TEXT NOT NULL,
  postal_code TEXT NOT NULL,
  country TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

-- Enable RLS on orders
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their own orders" ON public.orders FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create their own orders" ON public.orders FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Create order_items table
CREATE TABLE public.order_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID REFERENCES public.orders(id) ON DELETE CASCADE NOT NULL,
  product_id UUID REFERENCES public.products(id) ON DELETE SET NULL,
  product_name TEXT NOT NULL,
  product_price DECIMAL(10,2) NOT NULL,
  quantity INTEGER NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

-- Enable RLS on order_items
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their own order items" ON public.order_items FOR SELECT USING (
  EXISTS (SELECT 1 FROM public.orders WHERE orders.id = order_items.order_id AND orders.user_id = auth.uid())
);
CREATE POLICY "Users can create their own order items" ON public.order_items FOR INSERT WITH CHECK (
  EXISTS (SELECT 1 FROM public.orders WHERE orders.id = order_items.order_id AND orders.user_id = auth.uid())
);

-- Insert categories
INSERT INTO public.categories (name, description, image_url) VALUES
('Clothing', 'Premium apparel for every occasion', 'https://images.unsplash.com/photo-1489987707025-afc232f7ea0f?w=400'),
('Electronics', 'Latest gadgets and tech essentials', 'https://images.unsplash.com/photo-1498049794561-7780e7231661?w=400'),
('Accessories', 'Complete your look with our curated accessories', 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400');

-- Insert 50 products
INSERT INTO public.products (name, description, price, original_price, image_url, category_id, is_featured, is_new_arrival, discount_percent, rating, review_count) VALUES
-- Clothing (20 products)
('Classic Oxford Shirt', 'Premium cotton oxford shirt with button-down collar', 89.00, 129.00, 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=400', (SELECT id FROM categories WHERE name = 'Clothing'), true, false, 31, 4.8, 124),
('Cashmere Sweater', 'Luxurious pure cashmere pullover sweater', 295.00, NULL, 'https://images.unsplash.com/photo-1434389677669-e08b4cac3105?w=400', (SELECT id FROM categories WHERE name = 'Clothing'), true, false, 0, 4.9, 89),
('Denim Jacket', 'Classic vintage-wash denim jacket', 195.00, 245.00, 'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=400', (SELECT id FROM categories WHERE name = 'Clothing'), true, false, 20, 4.8, 156),
('Linen Blazer', 'Lightweight summer linen blazer', 245.00, 349.00, 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=400', (SELECT id FROM categories WHERE name = 'Clothing'), true, false, 30, 4.6, 67),
('Organic Cotton Tee', 'Sustainable organic cotton basic t-shirt', 45.00, NULL, 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400', (SELECT id FROM categories WHERE name = 'Clothing'), false, true, 0, 4.7, 203),
('Wool Overcoat', 'Classic tailored wool blend overcoat', 425.00, 550.00, 'https://images.unsplash.com/photo-1539533018447-63fcce2678e3?w=400', (SELECT id FROM categories WHERE name = 'Clothing'), false, true, 23, 4.9, 45),
('Slim Fit Chinos', 'Modern slim fit cotton chino pants', 85.00, NULL, 'https://images.unsplash.com/photo-1473966968600-fa801b869a1a?w=400', (SELECT id FROM categories WHERE name = 'Clothing'), false, true, 0, 4.5, 178),
('Merino Wool Polo', 'Fine merino wool polo shirt', 125.00, NULL, 'https://images.unsplash.com/photo-1625910513413-5fc3baa71e9c?w=400', (SELECT id FROM categories WHERE name = 'Clothing'), false, false, 0, 4.6, 92),
('Silk Blend Scarf', 'Elegant silk blend printed scarf', 75.00, 95.00, 'https://images.unsplash.com/photo-1601924994987-69e26d50dc26?w=400', (SELECT id FROM categories WHERE name = 'Clothing'), false, false, 21, 4.7, 56),
('Leather Belt', 'Genuine Italian leather belt', 65.00, NULL, 'https://images.unsplash.com/photo-1553062407-98eeb64c6a45?w=400', (SELECT id FROM categories WHERE name = 'Clothing'), false, false, 0, 4.8, 134),
('Linen Shirt', 'Relaxed fit pure linen shirt', 95.00, NULL, 'https://images.unsplash.com/photo-1598032895397-b9472444bf93?w=400', (SELECT id FROM categories WHERE name = 'Clothing'), false, false, 0, 4.5, 87),
('Corduroy Trousers', 'Classic wide-wale corduroy pants', 115.00, 145.00, 'https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?w=400', (SELECT id FROM categories WHERE name = 'Clothing'), false, false, 21, 4.4, 63),
('Knit Cardigan', 'Chunky cable knit cardigan', 165.00, NULL, 'https://images.unsplash.com/photo-1620799140408-edc6dcb6d633?w=400', (SELECT id FROM categories WHERE name = 'Clothing'), false, true, 0, 4.7, 78),
('Tailored Suit Jacket', 'Classic single-breasted suit jacket', 395.00, 495.00, 'https://images.unsplash.com/photo-1593030761757-71fae45fa0e7?w=400', (SELECT id FROM categories WHERE name = 'Clothing'), false, false, 20, 4.9, 34),
('Striped Dress Shirt', 'French cuff striped dress shirt', 110.00, NULL, 'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=400', (SELECT id FROM categories WHERE name = 'Clothing'), false, false, 0, 4.6, 145),
('Quilted Vest', 'Lightweight quilted gilet vest', 145.00, 185.00, 'https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=400', (SELECT id FROM categories WHERE name = 'Clothing'), false, false, 22, 4.5, 67),
('Cotton Hoodie', 'Premium cotton fleece hoodie', 95.00, NULL, 'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=400', (SELECT id FROM categories WHERE name = 'Clothing'), false, true, 0, 4.8, 234),
('Dress Pants', 'Wool blend tailored dress pants', 135.00, NULL, 'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?w=400', (SELECT id FROM categories WHERE name = 'Clothing'), false, false, 0, 4.6, 89),
('Bomber Jacket', 'Classic nylon bomber jacket', 175.00, 225.00, 'https://images.unsplash.com/photo-1592878904946-b3cd8ae243d0?w=400', (SELECT id FROM categories WHERE name = 'Clothing'), false, true, 22, 4.7, 156),
('Henley Shirt', 'Long sleeve cotton henley', 65.00, NULL, 'https://images.unsplash.com/photo-1618517351616-38fb9c5210c6?w=400', (SELECT id FROM categories WHERE name = 'Clothing'), false, false, 0, 4.5, 112),

-- Electronics (15 products)
('Wireless Noise-Canceling Headphones', 'Premium over-ear wireless headphones with ANC', 349.00, NULL, 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', (SELECT id FROM categories WHERE name = 'Electronics'), true, false, 0, 4.9, 312),
('Wireless Charging Pad', 'Fast wireless charging pad for all devices', 49.00, NULL, 'https://images.unsplash.com/photo-1586816879360-004f5b0c51e5?w=400', (SELECT id FROM categories WHERE name = 'Electronics'), false, false, 0, 4.5, 189),
('Wireless Earbuds Pro', 'True wireless earbuds with noise cancellation', 199.00, NULL, 'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=400', (SELECT id FROM categories WHERE name = 'Electronics'), true, false, 0, 4.8, 267),
('Smart Watch Series X', 'Advanced smartwatch with health monitoring', 429.00, 499.00, 'https://images.unsplash.com/photo-1579586337278-3befd40fd17a?w=400', (SELECT id FROM categories WHERE name = 'Electronics'), true, false, 14, 4.7, 198),
('Portable Bluetooth Speaker', 'Waterproof portable speaker with 360 sound', 129.00, 159.00, 'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=400', (SELECT id FROM categories WHERE name = 'Electronics'), false, true, 19, 4.6, 145),
('Mechanical Keyboard', 'RGB mechanical gaming keyboard', 159.00, NULL, 'https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?w=400', (SELECT id FROM categories WHERE name = 'Electronics'), false, false, 0, 4.8, 234),
('Wireless Mouse', 'Ergonomic wireless mouse with precision tracking', 79.00, 99.00, 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=400', (SELECT id FROM categories WHERE name = 'Electronics'), false, false, 20, 4.5, 178),
('USB-C Hub', 'Multi-port USB-C hub with HDMI', 69.00, NULL, 'https://images.unsplash.com/photo-1625842268584-8f3296236761?w=400', (SELECT id FROM categories WHERE name = 'Electronics'), false, true, 0, 4.4, 123),
('Tablet Stand', 'Adjustable aluminum tablet stand', 45.00, NULL, 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=400', (SELECT id FROM categories WHERE name = 'Electronics'), false, false, 0, 4.6, 89),
('Power Bank 20000mAh', 'High-capacity portable power bank', 59.00, 79.00, 'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=400', (SELECT id FROM categories WHERE name = 'Electronics'), false, true, 25, 4.7, 267),
('Webcam HD Pro', '4K webcam with autofocus and mic', 149.00, NULL, 'https://images.unsplash.com/photo-1587826080692-f439cd0b70da?w=400', (SELECT id FROM categories WHERE name = 'Electronics'), false, false, 0, 4.5, 156),
('Gaming Headset', 'Surround sound gaming headset', 89.00, 119.00, 'https://images.unsplash.com/photo-1599669454699-248893623440?w=400', (SELECT id FROM categories WHERE name = 'Electronics'), false, false, 25, 4.6, 198),
('Laptop Sleeve', 'Premium neoprene laptop sleeve', 39.00, NULL, 'https://images.unsplash.com/photo-1603302576837-37561b2e2302?w=400', (SELECT id FROM categories WHERE name = 'Electronics'), false, false, 0, 4.4, 134),
('Wireless Earbuds Sport', 'Sweatproof sports wireless earbuds', 79.00, 99.00, 'https://images.unsplash.com/photo-1606220945770-b5b6c2c55bf1?w=400', (SELECT id FROM categories WHERE name = 'Electronics'), false, true, 20, 4.5, 178),
('Smart Home Hub', 'Voice-controlled smart home hub', 129.00, NULL, 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400', (SELECT id FROM categories WHERE name = 'Electronics'), false, false, 0, 4.7, 145),

-- Accessories (15 products)
('Leather Wallet', 'Genuine leather bi-fold wallet', 89.00, NULL, 'https://images.unsplash.com/photo-1627123424574-724758594e93?w=400', (SELECT id FROM categories WHERE name = 'Accessories'), true, false, 0, 4.8, 234),
('Aviator Sunglasses', 'Classic metal frame aviator sunglasses', 159.00, 199.00, 'https://images.unsplash.com/photo-1511499767150-a48a237f0083?w=400', (SELECT id FROM categories WHERE name = 'Accessories'), true, false, 20, 4.7, 178),
('Canvas Backpack', 'Vintage canvas backpack with leather trim', 125.00, NULL, 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400', (SELECT id FROM categories WHERE name = 'Accessories'), false, true, 0, 4.6, 145),
('Leather Watch Strap', 'Premium leather watch band', 45.00, NULL, 'https://images.unsplash.com/photo-1594534475808-b18fc33b045e?w=400', (SELECT id FROM categories WHERE name = 'Accessories'), false, false, 0, 4.5, 89),
('Minimalist Watch', 'Clean design minimalist wristwatch', 195.00, 245.00, 'https://images.unsplash.com/photo-1524805444758-089113d48a6d?w=400', (SELECT id FROM categories WHERE name = 'Accessories'), true, false, 20, 4.8, 267),
('Leather Messenger Bag', 'Full-grain leather messenger bag', 295.00, NULL, 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=400', (SELECT id FROM categories WHERE name = 'Accessories'), false, true, 0, 4.9, 123),
('Wool Beanie', 'Merino wool knit beanie', 35.00, NULL, 'https://images.unsplash.com/photo-1576871337622-98d48d1cf531?w=400', (SELECT id FROM categories WHERE name = 'Accessories'), false, false, 0, 4.5, 156),
('Leather Card Holder', 'Slim leather card holder', 49.00, NULL, 'https://images.unsplash.com/photo-1606503153255-59d7b85b4a60?w=400', (SELECT id FROM categories WHERE name = 'Accessories'), false, false, 0, 4.6, 198),
('Canvas Tote Bag', 'Heavy-duty canvas tote bag', 55.00, 69.00, 'https://images.unsplash.com/photo-1544816155-12df9643f363?w=400', (SELECT id FROM categories WHERE name = 'Accessories'), false, true, 20, 4.4, 112),
('Leather Gloves', 'Cashmere-lined leather gloves', 95.00, NULL, 'https://images.unsplash.com/photo-1584804916870-ab9f3e60f7e3?w=400', (SELECT id FROM categories WHERE name = 'Accessories'), false, false, 0, 4.7, 67),
('Travel Duffel Bag', 'Weekender travel duffel bag', 175.00, 225.00, 'https://images.unsplash.com/photo-1553062407-98eeb64c6a46?w=400', (SELECT id FROM categories WHERE name = 'Accessories'), false, false, 22, 4.8, 89),
('Keychain Organizer', 'Leather key organizer', 29.00, NULL, 'https://images.unsplash.com/photo-1580377968114-d1c1d759e9cb?w=400', (SELECT id FROM categories WHERE name = 'Accessories'), false, false, 0, 4.3, 134),
('Laptop Backpack', 'Business laptop backpack with USB port', 145.00, 185.00, 'https://images.unsplash.com/photo-1622560480605-d83c853bc5c3?w=400', (SELECT id FROM categories WHERE name = 'Accessories'), false, true, 22, 4.6, 178),
('Round Sunglasses', 'Vintage round frame sunglasses', 129.00, NULL, 'https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=400', (SELECT id FROM categories WHERE name = 'Accessories'), false, false, 0, 4.5, 145),
('Chronograph Watch', 'Classic chronograph wristwatch', 325.00, 395.00, 'https://images.unsplash.com/photo-1587836374828-4dbafa94cf0e?w=400', (SELECT id FROM categories WHERE name = 'Accessories'), false, false, 18, 4.9, 78);

-- Create function to update timestamps
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SET search_path = public;

-- Create triggers for automatic timestamp updates
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON public.products FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_cart_items_updated_at BEFORE UPDATE ON public.cart_items FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON public.orders FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();