# Knapsack problem
### Decision version, solved using brute force and branch and bound
#### NI-KOP 2021


Description of the problem:

Given set of items {x<sub>1</sub>, ... x<sub>n</sub>} with respective
prices {c<sub>1</sub>, ... c<sub>n</sub>} and weights 
{w<sub>1</sub>, ... w<sub>n</sub>}, can you find subset of these
items so that the sum of prices is at least **B** and the sum of their
weights does not exceed **M**?

This problem is known to be NP-complete, which means 
there is no known algorithm both correct 
and fast (polynomial-time) in all cases.

## Brute force
To find solution for this problem I first implemented
naive solution using *brute force*. I created superset of all items
and checked the price and weight of each subset. Due to high
computational demans I was able to solve this problem
only up to 15 items.

### Results for *brute force*

| N of items | Average | Median | Std. | Min | Max |
|------------|:-------:|:------:|:----:|:---:|:---:|
| 4          |  9      |  7     | 6.48 | 1   | 16  |
| 10         |    570  |   854  |474.82|1    |1024 |
| 15         |    18287|  30847 |  15401.71|1    |32768|
| --         |         |        |      |     |     |
| --         |         |        |      |     |     |
| --         |         |        |      |     |     |


## Branch and bound

1. Sort all items in decreasing order of V/W so that upper bound
    can be computed using Greedy Approach.
    (The nodes taken in the image are accordingly.)
2. Initialize profit, max = 0 
3. Create an empty queue, Q. 
4. Create a dummy node of decision tree and enqueue it to Q. Profit and weight of dummy node are 0. 
5. Do while (Q is not empty).
- Extract an item from Q. Let the item be x. 
- Compute profit of next level node. If the profit is more than max, then update max. (Profit from root to this node (include this node)).
- Compute bound of next level node. If bound is more than max, then add next level node to Q.(Upper Bound of the maximum Profit in subtree of this node)
- Consider the case when next level node is not considered as part of solution and add a node to queue with level as next, but weight and profit without considering next level nodes.

Description taken from [medium.com](https://medium.com/@leenancyparmar1999/knapsack-problem-branch-and-bound-approach-1fdab6d9a241).

## Results for *branch and bound*

| N of items | Average | Median | Std. | Min | Max |
|------------|:-------:|:------:|:----:|:---:|:---:|
| 4          |    8    | 8      | 0.56 |  8  | 12  |
| 10         |    21   |   20   |  3.39|20   |64   |
| 15         |    31   |  30    |  4.13|30   |  62 |
| 20         |    42   |  40    |  6.12|40   | 92  |
| 30         |    64   |60      | 13.32| 60  | 242 |
| 40         |   84    |   80   |12.64 |  80 |   198|