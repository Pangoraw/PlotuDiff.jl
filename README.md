# PlotuDiff.jl

![image](https://user-images.githubusercontent.com/9824244/142050922-3d1e28d8-872f-4260-b65d-48dda4383733.png)

This Julia package implements a set of diffing utilities to more easily _visualize differences_ between two inputs. Currently, this package focuses on differences between strings but the goal is to expand to all kind of Julia objects like dictionnaries, images and more in a composable manner.

## References

 - [E. Myers (1986). "An O(ND) Difference Algorithm and Its Variations".](https://neil.fraser.name/writing/diff/myers.pdf)
 - [This cool blog post](https://blog.jcoglan.com/2017/02/12/the-myers-diff-algorithm-part-1/) for the Myers algorithm implementation
