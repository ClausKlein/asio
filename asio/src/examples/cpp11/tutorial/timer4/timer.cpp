//
// timer4/timer.cpp
// ~~~~~~~~~~~~~~~~
//
// Copyright (c) 2003-2025 Christopher M. Kohlhoff (chris at kohlhoff dot com)
//
// Distributed under the Boost Software License, Version 1.0. (See accompanying
// file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
//

#include <functional>
#include <iostream>
#include "asio/io_context.hpp"
#include "asio/steady_timer.hpp"

class printer
{
public:
  printer(asio::io_context& io)
    : timer_(io, asio::chrono::seconds(1))
  {
    timer_.async_wait([this](const asio::error_code& /*ec*/) { print(); });
  }

  ~printer()
  {
    std::cout << "Final count is " << count_ << std::endl;
  }

  void print()
  {
    if (count_ < 5)
    {
      std::cout << count_ << std::endl;
      ++count_;

      timer_.expires_at(timer_.expiry() + asio::chrono::seconds(1));
      timer_.async_wait([this](const asio::error_code& /*ec*/) { print(); });
    }
  }

private:
  asio::steady_timer timer_;
  int count_{0};
};

auto main() -> int
{
  asio::io_context io;
  printer p(io);
  io.run();

  return 0;
}
