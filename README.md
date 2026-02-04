# exit_0: A Terminal-Based Linux Learning RPG

Full documentation, lab guides, and usage notes are available here:
https://vonds.github.io/docs.html

exit_0 is a terminal-based learning game designed to teach Linux through hands-on practice, repetition, and realism. I originally built this project as a way to teach myself Linux in a way that mirrored how systems administrators actually learn: by working directly in the terminal, making mistakes, fixing them, and repeating that process until commands and concepts became second nature. Over time, the project evolved into a structured, RPG-inspired lab environment that blends technical accuracy with motivation, progression, and measurable skill growth.

The core idea behind exit_0 is simple: Linux mastery is earned through consistent interaction with the system, not passive reading. This project breaks Linux concepts into focused labs, presents them through an interactive terminal interface, and tracks progress locally so learners can build real fluency over time. The name “exit_0” reflects the goal of every lab and command successful execution.

# How to Run and Use exit_0

exit_0 runs entirely in the terminal and is intended for use on Unix-like systems such as Linux or macOS. After cloning the repository or extracting the project directory, begin by navigating into the root of the project.

```cd exit_0```

Before running the application for the first time, ensure the scripts are executable. If needed, you can update permissions with:

```chmod +x *.sh```
```chmod +x scripts/*.sh labs/*.sh```


The primary entry point into the application is the welcome menu, which initializes the environment and provides access to all available functionality. To start the game, run:

```exit_0/scripts/welcome_menu.sh```

To start the game from the project root, run:

```./scripts/welcome_menu.sh```

Once launched, you’ll be presented with an interactive terminal menu. Navigation is handled using simple numeric selections and standard input. From the welcome menu, you can enter the labs interface, review progress and stats, or explore other available options.

Labs are scenario-based and designed to simulate realistic Linux usage and system administration tasks. You are expected to engage directly with the terminal; running commands, interpreting output, and responding to prompts as you would on a real system. Successful completion of a lab awards experience points and records your progress locally, allowing you to exit and resume at any time.

Progress tracking, experience points, and UI feedback are handled automatically in the background. Some additional features; such as expanded progression mechanics, deeper analytics, and additional UI polish—are already partially implemented and functional, but are still works in progress. The core lab system, however, is stable and fully usable.

# What Makes exit_0 Different

exit_0 is intentionally built using Bash and standard Unix tools rather than higher-level frameworks. This keeps the environment close to real production systems, makes the codebase easy to inspect, and ensures that users are learning skills that transfer directly to real-world Linux administration. The project emphasizes realistic command usage, predictable system behavior, and repetition.

In the interest of building a functional learning tool quickly, I made deliberate use of AI-assisted development for parts of the system I was less familiar with and to accelerate the creation of lab content. The goal was not to outsource understanding, but to remove friction so I could focus on learning Linux itself while still shipping a usable tool. All AI-assisted scripts and labs were reviewed, tested, and refined through hands-on use in the terminal, and many were modified or rewritten as my understanding deepened.

This reflects a realistic engineering workflow: identifying gaps, using available tools to unblock progress, and validating solutions through direct interaction with the system. The codebase captures not just a finished product, but an authentic learning process and an iterative approach to problem-solving.

# Intended Audience

exit_0 is designed for learners who want to move beyond surface-level Linux familiarity and for engineers who value depth through hands-on practice. It is particularly useful for those preparing for roles in system administration, DevOps, site reliability, or infrastructure engineering. At the same time, the project is structured cleanly enough that experienced engineers can quickly understand the codebase and extend it without unnecessary complexity.

# Collaboration and Contributions

This project is actively evolving and is being built in the open. I’m open to collaboration from others who are interested in Linux education, terminal-based tooling, or improving the realism and depth of technical labs. Contributions might include new labs, refinements to existing scripts, UI improvements, or structural refactors that improve maintainability.

If you have ideas, want to fix something, or are interested in helping shape the direction of the project, contributions and thoughtful discussion are welcome. The long-term goal is for exit_0 to continue growing into a high-quality, community-informed Linux learning environment.
