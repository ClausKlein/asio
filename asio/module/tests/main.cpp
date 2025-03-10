#include "main.hpp"

// NOLINTNEXTLINE(bugprone-exception-escape)
auto main() -> int
{
    return bench::main_impl();  // NOLINT(clang-analyzer-core.CallAndMessage)
}
