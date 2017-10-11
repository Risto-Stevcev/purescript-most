module Test.Data.Most where

import Data.Most

import Control.Coroutine (Consumer, Process, Producer, await, runProcess, ($$))
import Control.Coroutine.Aff (produce)
import Control.Monad.Aff (Aff, parallel, sequential)
import Control.Monad.Aff.AVar (AVAR)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Unsafe (unsafePerformEff)
import Control.Monad.Rec.Class (forever)
import Control.Monad.ST (ST, STRef, modifySTRef, newSTRef, readSTRef)
import Control.Monad.Trans.Class (lift)
import Control.Observable.Class (fromIterable, fromObservable, subscribe, make)
import DOM.Event.Types (Event)
import Data.Either (Either(..))
import Data.Tuple (Tuple(..))
import Prelude (class Applicative, class Semigroup, Unit, bind, discard, map, pure, unit, ($), (*), (*>), (<$>), (<*>), (<>), (+))
import Test.Spec (describe, it)
import Test.Spec.Assertions (shouldEqual)
import Test.Spec.Reporter.Console (consoleReporter)
import Test.Spec.Runner (RunnerEffects, run)


foreign import data Emitter ∷ Type → Type
foreign import emitter ∷ ∀ a e. Eff e (Emitter a)
foreign import emit' ∷ ∀ a e. Emitter a → String → a → Eff e Unit
foreign import listenerCount ∷ ∀ a. Emitter a → String → Int
foreign import stringifyEvent ∷ Event → String


data StreamEvent a = Next a | Error | Complete

observableProducer
  ∷ ∀ e a. Stream a
  → Producer (StreamEvent a) (Aff (avar ∷ AVAR | e)) Unit
observableProducer observable = produce \emit → do
   _ ← subscribe observable {
     next:     \a → unsafePerformEff $ emit (Left $ Next a),
     error:    \_ → unsafePerformEff $ emit (Left Error),
     complete: \_ → unsafePerformEff $ do
       emit (Left Complete)
       emit (Right unit)
   }
   pure unit

observableConsumer
  ∷ ∀ a e f. Applicative f ⇒ Semigroup (f a) ⇒ STRef Unit (f a)
  → Consumer (StreamEvent a) (Aff (st ∷ ST Unit | e)) Unit
observableConsumer ref = forever do
  e ← await
  lift $ liftEff $ case e of
    Next a   → do
      _ ← modifySTRef ref (_ <> pure a)
      pure ref
    Error    → pure ref
    Complete → pure ref

observableProcess
  ∷ ∀ a e f. Applicative f ⇒ Semigroup (f a) ⇒ STRef Unit (f a) → Stream a
  → Process (Aff (st ∷ ST Unit, avar ∷ AVAR | e)) Unit
observableProcess ref observable = observableProducer observable $$ observableConsumer ref


observableCollect
  ∷ ∀ a e. Stream a → Aff (st ∷ ST Unit, avar ∷ AVAR | e) (Array a)
observableCollect observable = do
  ref ← liftEff $ newSTRef []
  runProcess $ observableProcess ref observable
  liftEff $ readSTRef ref



main ∷ Eff (RunnerEffects (st ∷ ST Unit)) Unit
main = run [consoleReporter] do
  describe "purescript-most" do
    describe "fromIterable" do
      it "should create an observable from an iterable" do
        o ← liftEff $ fromIterable [1, 1, 2, 3, 5, 8]
        v ← observableCollect o
        v `shouldEqual` [1, 1, 2, 3, 5, 8]

    describe "fromObservable" do
      it "should create an observable from another observable" do
        o ← liftEff do
          o' ← fromIterable [1, 1, 2, 3, 5, 8]
          fromObservable $ (_ * 2) <$> o'
        v ← observableCollect o
        v `shouldEqual` [2, 2, 4, 6, 10, 16]

    describe "make" do
      it "should create an observable from a value" do
        o ← liftEff $ make "foo"
        v ← observableCollect o
        v `shouldEqual` ["foo"]

    describe "fromEvent" do
      it "should create an observable from an event" do
        e ← liftEff emitter
        let o = take 1 $ fromEvent "foo" e

        ref ← liftEff $ newSTRef []
        let p = observableProcess ref o
        _ ← sequential $
          Tuple <$> parallel (runProcess p)
                <*> parallel (liftEff $ emit' e "foo" 123 *> emit' e "foo" 234)
        v ← liftEff $ readSTRef ref

        map stringifyEvent v `shouldEqual` ["123"]

    describe "scan" do
      it "should scan an observable" do
        o ← liftEff $ fromIterable [1, 1, 2, 3, 5, 8]
        v ← observableCollect $ scan (+) 0 o
        v `shouldEqual` [0, 1, 2, 4, 7, 12, 20]

