//
// detail/null_thread.hpp
// ~~~~~~~~~~~~~~~~~~~~~~
//
// Copyright (c) 2003-2011 Christopher M. Kohlhoff (chris at kohlhoff dot com)
//
// Distributed under the Boost Software License, Version 1.0. (See accompanying
// file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
//

#ifndef ASIO_DETAIL_NULL_THREAD_HPP
#define ASIO_DETAIL_NULL_THREAD_HPP

#if defined(_MSC_VER) && (_MSC_VER >= 1200)
# pragma once
#endif // defined(_MSC_VER) && (_MSC_VER >= 1200)

#include "RCF/external/asio/asio/detail/config.hpp"

#if !defined(BOOST_HAS_THREADS) || defined(ASIO_DISABLE_THREADS)

#include "RCF/external/asio/asio/detail/noncopyable.hpp"
#include "RCF/external/asio/asio/detail/throw_error.hpp"
#include "RCF/external/asio/asio/error.hpp"

#include "RCF/external/asio/asio/detail/push_options.hpp"

namespace asio {
namespace detail {

class null_thread
  : private noncopyable
{
public:
  // Constructor.
  template <typename Function>
  null_thread(Function, unsigned int = 0)
  {
    asio::detail::throw_error(
        asio::error::operation_not_supported, "thread");
  }

  // Destructor.
  ~null_thread()
  {
  }

  // Wait for the thread to exit.
  void join()
  {
  }
};

} // namespace detail
} // namespace asio

#include "RCF/external/asio/asio/detail/pop_options.hpp"

#endif // !defined(BOOST_HAS_THREADS) || defined(ASIO_DISABLE_THREADS)

#endif // ASIO_DETAIL_NULL_THREAD_HPP
