@echo off
more > render-local-registry.tmp0
bash render-local-registry <render-local-registry.tmp0 >render-local-registry.tmp1 2>render-local-registry.tmp2
more < render-local-registry.tmp1
del render-local-registry.tmp?
