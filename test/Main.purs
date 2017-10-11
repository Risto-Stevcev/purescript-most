module Test.Main where

import Prelude
import Control.Monad.Eff (Eff)
import Control.Monad.ST (ST)
import Test.Spec.Runner (RunnerEffects)
import Test.Data.Most (main) as Test

main ∷ Eff (RunnerEffects (st ∷ ST Unit)) Unit
main = Test.main
