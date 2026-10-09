## Using dart analyze

- Don't run `flutter analyze <paths>` — scoping to paths is extremely slow and the
  command wrapper will time out.
- Run `flutter analyze` (whole project), then `grep` the output if you only care
  about specific files or issues.

## Code Style

- always prefer names arguments
- constructors always only save variables as is, any computation is in factories
- descriptive names
- little to no comments
- run formatter at the end of code changes
- aim for 100% test pass &  100% branch coverage 
