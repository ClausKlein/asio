#include <print>
#include <memory>
#include <utility>
#include "asio/io_context.hpp"
#include "asio/steady_timer.hpp"

class printer {
public:
    explicit printer(asio::io_context& io) : timer_(io, asio::chrono::seconds(1)) {
        timer_.async_wait([this](const asio::error_code& /*ec*/) { print(); });
    }

    ~printer() noexcept {
        std::print("Final count is {}\n", count_);
    }

    void print() {
        if (count_ < kMaxCount) {
            std::print("{}\n", count_);
            ++count_;

            timer_.expires_at(timer_.expiry() + asio::chrono::seconds(1));
            timer_.async_wait([this](const asio::error_code& /*ec*/) { print(); });
        }
    }

private:
    static constexpr int kMaxCount = 5;
    asio::steady_timer timer_;
    int count_ = 0;
};

auto main() -> int {
    try {
        asio::io_context io;
        auto p = std::make_unique<printer>(io);
        io.run();
    } catch (const std::exception& e) {
        std::print("Error: {}\n", e.what());
        return 1;
    }

    return 0;
}
