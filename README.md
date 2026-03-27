# Quantum-Inspired Grey Wolf Optimizer (QGWO)

A MATLAB implementation of the **Quantum-inspired Grey Wolf Optimizer (QGWO)** — an enhanced metaheuristic that extends the classical Grey Wolf Optimizer (GWO) with a probabilistic, quantum-behaved position update mechanism inspired by Quantum-behaved Particle Swarm Optimization (QPSO).

> ⚠️ **Work in Progress** — This repository is under active development. Benchmark results and additional test cases will be updated as the project matures.

---

## Overview

The Grey Wolf Optimizer mimics the social hierarchy and hunting strategy of grey wolves. QGWO extends this by replacing the deterministic position update with a **quantum-inspired stochastic rule**, allowing wolves to probabilistically tunnel through local optima — improving both global search capability and convergence precision.

### Key Contributions

- Introduces a **logarithmic quantum jump** term `ln(1/u)` that generates heavy-tailed step lengths, enabling large exploration jumps early and fine exploitation later.
- Uses a **local attractor** constructed stochastically from the three leader wolves (α, β, δ), rather than a fixed deterministic combination.
- Employs a **contraction–expansion coefficient** `β(t)` that decays linearly over iterations to balance exploration vs. exploitation.
- Preserves GWO's hierarchical leadership structure and **O(N · T · d)** computational complexity.

---

## Algorithm

### Classical GWO Position Update

Each wolf updates its position relative to the three best wolves:

$$\vec{X}(t+1) = \frac{\vec{X}_1 + \vec{X}_2 + \vec{X}_3}{3}$$

### QGWO Position Update

The quantum-inspired update rule replaces the above with:

$$\vec{X}_i(t+1) = \vec{P}_i \pm \beta(t) \cdot \left| \vec{X}_i(t) - \text{mbest} \right| \cdot \ln\!\left(\frac{1}{u}\right)$$

Where:
- `mbest = (Xα + Xβ + Xδ) / 3` — mean best position of the three leaders
- `P_i` — local attractor, a stochastic weighted combination of the three leaders
- `u ~ U(0,1)` — uniform random vector
- `β(t) = 1.5 − 1.4 · (t/T)` — contraction–expansion coefficient (decays from 1.5 → 0.1)
- `ln(1/u)` — quantum tunneling factor producing heavy-tailed step lengths

The `±` sign is chosen randomly with equal probability, and a third branch (`P_i` alone) is also sampled — each with probability 1/3.

### Pseudocode

```
Initialize population X_i randomly in [lb, ub]
Evaluate fitness f(X_i) for all wolves
Identify α, β, δ wolves

for t = 1 to T:
    Compute mbest = (Xα + Xβ + Xδ) / 3
    for each wolf i:
        Generate random weights φ1, φ2, φ3
        Compute local attractor P_i
        Generate u ~ U(0,1), compute X_i(t+1) via quantum update rule
        Apply boundary control to keep X_i within [lb, ub]
        Greedy update: accept new position only if fitness improves
    Update α, β, δ based on new fitness values

Return α as best solution
```

---

## Repository Structure

```
QGWO/
├── QGWO.m       # Core QGWO algorithm
├── main.m       # Test harness: benchmarks F1–F23, multi-run statistics
├── Spbd.m       # Boundary handling utility (stochastic reinitialization)
└── README.md
```

> **Note:** The benchmark function provider `BM.m` is required to run `main.m`. It is not yet included in this repository and will be added in a future update.

---

## Usage

### Running Benchmarks

Open `main.m` in MATLAB and run. By default it tests functions **F1–F23** over **10 independent runs** with a population of **50 wolves** and **500 iterations**.

```matlab
Agent = 50;    % population size
Gen   = 500;   % iterations
Runs  = 10;    % independent runs
mode  = "benchmark";
```

Output per function:
```
--- Running F1 (benchmark test) ---
Run 1/10 ...
...
→ F1 results: Best = 0.0000e+00 | Mean = 1.2300e-05 | Std = 3.4500e-06
```

### Using QGWO in Your Own Code

```matlab
% Define your objective function
f = @(x) sum(x.^2);   % example: sphere function

lb  = -100;   % lower bound
ub  =  100;   % upper bound
dim =   30;   % dimensionality

[BestFitness, BestPos, convergence_curve] = QGWO(50, 500, ub, lb, dim, f);

% Plot convergence
semilogy(convergence_curve, 'LineWidth', 2);
xlabel('Iteration'); ylabel('Best Fitness');
title('QGWO Convergence');
```

### Switching to Engineering Problems

In `main.m`, change the mode:

```matlab
mode = "engineering";  % uses Get_Functions_details.m
```

---

## Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `MaxWolves` | 50 | Population size |
| `MaxIter` | 500 | Maximum iterations |
| `β(t)` | 1.5 → 0.1 | Contraction–expansion coefficient |
| `c1, c2` | 2.05, 2.05 | Local attractor weighting constants |

---

## Requirements

- MATLAB R2018b or later (no additional toolboxes required)
- `BM.m` — benchmark function suite (to be added)
- `Get_Functions_details.m` — engineering problem definitions (to be added)

---

## Results

Benchmark results across F1–F23 (unimodal, multimodal, fixed-dimension) will be published here once testing is finalized.

---

## Citation

If you use this code in your research, please cite:

```
Mal, M. (2025). Quantum-Inspired Grey Wolf Optimizer (QGWO).
GitHub: https://github.com/YOUR_USERNAME/QGWO
```

---

## License

This project is licensed under the MIT License. See `LICENSE` for details.

---

## Author

**Manan Mal** — *November 2025*  
Feel free to open an issue or submit a pull request for suggestions and improvements.
