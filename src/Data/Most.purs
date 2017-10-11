module Data.Most
  ( fromEvent
  , fromEvent'
  , scan
  , take
  , Stream
  ) where

import Prelude

import Control.Monad.Eff (Eff, kind Effect)
import Control.Observable.Class (class Observable, Listeners, Subscription)
import DOM.Event.Types (Event)
import Data.Iterable (class Iterable)
import Data.Monoid (class Monoid)

foreign import data MOST ∷ Effect
foreign import data Stream ∷ Type → Type

foreign import _of ∷ ∀ a e. a → Eff e (Stream a)
foreign import _just ∷ ∀ a. a → Stream a
foreign import _subscribe ∷ ∀ a e. Stream a → Listeners a → Eff e Subscription
foreign import _fromIterable ∷ ∀ a e f. Iterable (f a) a ⇒ f a → Eff e (Stream a)
foreign import _fromObservable ∷ ∀ a e. Stream a → Eff e (Stream a)
foreign import _map ∷ ∀ a b. (a → b) → Stream a → Stream b
foreign import _apply ∷ ∀ a b. Stream (a → b) → Stream a → Stream b
foreign import _bind ∷ ∀ a b. Stream a → (a → Stream b) → Stream b
foreign import _append ∷ ∀ a. Stream a → Stream a → Stream a
foreign import _mempty ∷ ∀ a. Stream a
foreign import _fromEvent ∷ ∀ a. String → a → Boolean → Stream Event
foreign import _scan ∷ ∀ a b. (b → a → b) → b → Stream a → Stream b
foreign import _take ∷ ∀ a. Int → Stream a → Stream a

instance observableStream ∷ Observable Stream where
  subscribe = _subscribe
  make = _of
  fromIterable = _fromIterable
  fromObservable = _fromObservable

instance functorStream ∷ Functor Stream where
  map = _map

instance applyStream ∷ Apply Stream where
  apply = _apply

instance applicativeStream ∷ Applicative Stream where
  pure = _just

instance bindStream ∷ Bind Stream where
  bind = _bind

instance monadStream ∷ Monad Stream

instance semigroupStream ∷ Semigroup (Stream a) where
  append = _append

instance monoidStream ∷ Monoid (Stream a) where
  mempty = _mempty


fromEvent ∷ ∀ a. String → a → Stream Event
fromEvent eventType source = _fromEvent eventType source false

fromEvent' ∷ ∀ a. String → a → Boolean → Stream Event
fromEvent' = _fromEvent

scan ∷ ∀ a b. (b → a → b) → b → Stream a → Stream b
scan = _scan

take ∷ ∀ a. Int → Stream a → Stream a
take = _take
