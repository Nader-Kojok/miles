export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export interface Database {
  public: {
    Tables: {
      profiles: {
        Row: {
          id: string
          phone: string | null
          full_name: string | null
          avatar_url: string | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id: string
          phone?: string | null
          full_name?: string | null
          avatar_url?: string | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          phone?: string | null
          full_name?: string | null
          avatar_url?: string | null
          created_at?: string
          updated_at?: string
        }
      }
      categories: {
        Row: {
          id: string
          name: string
          slug: string
          icon: string | null
          description: string | null
          image_url: string | null
          parent_id: string | null
          display_order: number
          is_active: boolean
          created_at: string
        }
        Insert: {
          id?: string
          name: string
          slug: string
          icon?: string | null
          description?: string | null
          image_url?: string | null
          parent_id?: string | null
          display_order?: number
          is_active?: boolean
          created_at?: string
        }
        Update: {
          id?: string
          name?: string
          slug?: string
          icon?: string | null
          description?: string | null
          image_url?: string | null
          parent_id?: string | null
          display_order?: number
          is_active?: boolean
          created_at?: string
        }
      }
      products: {
        Row: {
          id: string
          name: string
          slug: string
          description: string | null
          price: number
          compare_at_price: number | null
          category_id: string | null
          image_url: string | null
          images: string[] | null
          in_stock: boolean
          stock_quantity: number
          sku: string | null
          brand: string | null
          weight: number | null
          dimensions: Json | null
          tags: string[] | null
          is_featured: boolean
          is_active: boolean
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          name: string
          slug: string
          description?: string | null
          price: number
          compare_at_price?: number | null
          category_id?: string | null
          image_url?: string | null
          images?: string[] | null
          in_stock?: boolean
          stock_quantity?: number
          sku?: string | null
          brand?: string | null
          weight?: number | null
          dimensions?: Json | null
          tags?: string[] | null
          is_featured?: boolean
          is_active?: boolean
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          name?: string
          slug?: string
          description?: string | null
          price?: number
          compare_at_price?: number | null
          category_id?: string | null
          image_url?: string | null
          images?: string[] | null
          in_stock?: boolean
          stock_quantity?: number
          sku?: string | null
          brand?: string | null
          weight?: number | null
          dimensions?: Json | null
          tags?: string[] | null
          is_featured?: boolean
          is_active?: boolean
          created_at?: string
          updated_at?: string
        }
      }
      orders: {
        Row: {
          id: string
          order_number: string
          user_id: string | null
          subtotal: number
          shipping_cost: number
          tax: number
          discount: number
          total: number
          status: 'pending' | 'confirmed' | 'processing' | 'shipped' | 'delivered' | 'cancelled'
          payment_status: 'pending' | 'paid' | 'failed' | 'refunded'
          payment_method: string | null
          shipping_address: Json
          customer_notes: string | null
          admin_notes: string | null
          created_at: string
          updated_at: string
          confirmed_at: string | null
          shipped_at: string | null
          delivered_at: string | null
        }
        Insert: {
          id?: string
          order_number: string
          user_id?: string | null
          subtotal: number
          shipping_cost?: number
          tax?: number
          discount?: number
          total: number
          status?: 'pending' | 'confirmed' | 'processing' | 'shipped' | 'delivered' | 'cancelled'
          payment_status?: 'pending' | 'paid' | 'failed' | 'refunded'
          payment_method?: string | null
          shipping_address: Json
          customer_notes?: string | null
          admin_notes?: string | null
          created_at?: string
          updated_at?: string
          confirmed_at?: string | null
          shipped_at?: string | null
          delivered_at?: string | null
        }
        Update: {
          id?: string
          order_number?: string
          user_id?: string | null
          subtotal?: number
          shipping_cost?: number
          tax?: number
          discount?: number
          total?: number
          status?: 'pending' | 'confirmed' | 'processing' | 'shipped' | 'delivered' | 'cancelled'
          payment_status?: 'pending' | 'paid' | 'failed' | 'refunded'
          payment_method?: string | null
          shipping_address?: Json
          customer_notes?: string | null
          admin_notes?: string | null
          created_at?: string
          updated_at?: string
          confirmed_at?: string | null
          shipped_at?: string | null
          delivered_at?: string | null
        }
      }
      promo_codes: {
        Row: {
          id: string
          code: string
          description: string | null
          type: 'percentage' | 'fixed_amount'
          value: number
          min_purchase_amount: number | null
          max_discount_amount: number | null
          usage_limit: number | null
          usage_count: number
          is_active: boolean
          valid_from: string | null
          valid_until: string | null
          created_at: string
        }
        Insert: {
          id?: string
          code: string
          description?: string | null
          type: 'percentage' | 'fixed_amount'
          value: number
          min_purchase_amount?: number | null
          max_discount_amount?: number | null
          usage_limit?: number | null
          usage_count?: number
          is_active?: boolean
          valid_from?: string | null
          valid_until?: string | null
          created_at?: string
        }
        Update: {
          id?: string
          code?: string
          description?: string | null
          type?: 'percentage' | 'fixed_amount'
          value?: number
          min_purchase_amount?: number | null
          max_discount_amount?: number | null
          usage_limit?: number | null
          usage_count?: number
          is_active?: boolean
          valid_from?: string | null
          valid_until?: string | null
          created_at?: string
        }
      }
    }
  }
}
