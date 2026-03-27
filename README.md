# Quantum-Inspired Grey Wolf Optimizer (QGWO)

A MATLAB implementation of the **Quantum-inspired Grey Wolf Optimizer (QGWO)** — an enhanced metaheuristic that extends the classical Grey Wolf Optimizer (GWO) with a probabilistic, quantum-behaved position update mechanism inspired by Quantum-behaved Particle Swarm Optimization (QPSO).

> ⚠️ **Work in Progress** — This repository is under active development. Benchmark results, additional test cases, and documentation will be updated as the project matures.

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
├── QGWO.m                   # Core QGWO algorithm
├── main.m                   # Test harness: benchmarks F1–F23, multi-run statistics
├── BM.m                     # Benchmark function suite (F1–F23)
├── Get_Functions_details.m  # Engineering design problem definitions (F1–F6)
├── Spbd.m                   # Boundary handling utility (stochastic reinitialization)
└── README.md
```

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
- All required files are included in this repository — no external dependencies needed.

---

## Benchmark Functions

### Standard Benchmarks (`BM.m`) — F1 to F23

| # | Function | Type | Dim | Search Space |
|---|----------|------|-----|-------------|
| F1 | Sphere | Unimodal | 30 | [-100, 100] |
| F2 | Schwefel 2.22 | Unimodal | 30 | [-10, 10] |
| F3 | Schwefel 1.2 | Unimodal | 30 | [-100, 100] |
| F4 | Schwefel 2.21 | Unimodal | 30 | [-100, 100] |
| F5 | Rosenbrock | Unimodal | 30 | [-30, 30] |
| F6 | Step | Unimodal | 30 | [-100, 100] |
| F7 | Quartic with noise | Unimodal | 30 | [-1.28, 1.28] |
| F8 | Schwefel 2.26 | Multimodal | 30 | [-500, 500] |
| F9 | Rastrigin | Multimodal | 30 | [-5.12, 5.12] |
| F10 | Ackley | Multimodal | 30 | [-32, 32] |
| F11 | Griewank | Multimodal | 30 | [-600, 600] |
| F12 | Penalized 1 | Multimodal | 30 | [-50, 50] |
| F13 | Penalized 2 | Multimodal | 30 | [-50, 50] |
| F14 | Shekel's Foxholes | Fixed-dim | 2 | [-65.536, 65.536] |
| F15 | Kowalik | Fixed-dim | 4 | [-5, 5] |
| F16 | Six-Hump Camel | Fixed-dim | 2 | [-5, 5] |
| F17 | Branin | Fixed-dim | 2 | [-5,10]×[0,15] |
| F18 | Goldstein-Price | Fixed-dim | 2 | [-2, 2] |
| F19 | Hartman 3 | Fixed-dim | 3 | [0, 1] |
| F20 | Hartman 6 | Fixed-dim | 6 | [0, 1] |
| F21–F23 | Shekel Family | Fixed-dim | 4 | [0, 10] |

### Engineering Design Problems (`Get_Functions_details.m`) — F1 to F6

| # | Problem | Dim |
|---|---------|-----|
| F1 | Tension/Compression Spring | 3 |
| F2 | Pressure Vessel Design | 4 |
| F3 | Welded Beam Design | 4 |
| F4 | Speed Reducer | 7 |
| F5 | Gear Train Design | 4 |
| F6 | Three-Bar Truss Design | 2 |

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

This project is licensed under the **GNU General Public License v3.0**. See `LICENSE` for details. Any derivative works must also be open-sourced under the same license.

---

## Author

**Manan Mal** — *November 2025*  
Feel free to open an issue or submit a pull request for suggestions and improvements.
