{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE UndecidableInstances #-}

-- | Storable class
module ViperVM.Format.Binary.Storable
   ( StaticStorable (..)
   , RequiredPadding
   , Padding
   , PaddingEx
   , staticSizeOf
   , staticAlignment
   )
where

import GHC.TypeLits
import Data.Proxy
import qualified Foreign.Storable as FS

import ViperVM.Format.Binary.Word
import ViperVM.Format.Binary.Ptr
import ViperVM.Utils.Types (Modulo)

-- | A storable data in constant space whose size is known at compile time
class StaticStorable a where
   -- | Size of the stored data (in bytes)
   type SizeOf a    :: Nat

   -- | Alignment requirement (in bytes)
   type Alignment a :: Nat

   -- | Peek (read) a value from a memory address
   staticPeek :: Ptr a -> IO a

   -- | Poke (write) a value at the given memory address
   staticPoke :: Ptr a -> a -> IO ()


-- | Compute the required padding between a and b to respect b's alignment
type family RequiredPadding a b where
   RequiredPadding a b = Padding (SizeOf a) b

-- | Compute the required padding between the size sz and b to respect b's alignment
type family Padding (sz :: Nat) b where
   Padding sz b = PaddingEx (Modulo sz (Alignment b)) (Alignment b)

type family PaddingEx (m :: Nat) (a :: Nat) where
   PaddingEx 0 a = 0
   PaddingEx m a = a - m


-- | Get statically known size
staticSizeOf :: forall a v.
   ( StaticStorable a
   , v ~ SizeOf a
   , KnownNat v
   ) => a -> Word
staticSizeOf _ = fromIntegral (natVal (Proxy :: Proxy v))

-- | Get statically known alignment
staticAlignment :: forall a v.
   ( StaticStorable a
   , v ~ SizeOf a
   , KnownNat v
   ) => a -> Word
staticAlignment _ = fromIntegral (natVal (Proxy :: Proxy v))


instance StaticStorable Word8 where
   type SizeOf    Word8 = 1
   type Alignment Word8 = 1
   staticPeek = FS.peek
   staticPoke = FS.poke

instance StaticStorable Word16 where
   type SizeOf    Word16 = 2
   type Alignment Word16 = 2
   staticPeek = FS.peek
   staticPoke = FS.poke

instance StaticStorable Word32 where
   type SizeOf    Word32 = 4
   type Alignment Word32 = 4
   staticPeek = FS.peek
   staticPoke = FS.poke

instance StaticStorable Word64 where
   type SizeOf    Word64 = 8
   type Alignment Word64 = 8
   staticPeek = FS.peek
   staticPoke = FS.poke

instance StaticStorable Int8 where
   type SizeOf    Int8 = 1
   type Alignment Int8 = 1
   staticPeek = FS.peek
   staticPoke = FS.poke

instance StaticStorable Int16 where
   type SizeOf    Int16 = 2
   type Alignment Int16 = 2
   staticPeek = FS.peek
   staticPoke = FS.poke

instance StaticStorable Int32 where
   type SizeOf    Int32 = 4
   type Alignment Int32 = 4
   staticPeek = FS.peek
   staticPoke = FS.poke

instance StaticStorable Int64 where
   type SizeOf    Int64 = 8
   type Alignment Int64 = 8
   staticPeek = FS.peek
   staticPoke = FS.poke
