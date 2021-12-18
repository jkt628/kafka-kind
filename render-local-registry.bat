@echo off
more > render-local-registry.tmp
bash render-local-registry < render-local-registry.tmp
del render-local-registry.tmp
