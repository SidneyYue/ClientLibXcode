//
// detail/impl/resolver_service_base.ipp
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
// Copyright (c) 2003-2011 Christopher M. Kohlhoff (chris at kohlhoff dot com)
//
// Distributed under the Boost Software License, Version 1.0. (See accompanying
// file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
//

#ifndef ASIO_DETAIL_IMPL_RESOLVER_SERVICE_BASE_IPP
#define ASIO_DETAIL_IMPL_RESOLVER_SERVICE_BASE_IPP

#if defined(_MSC_VER) && (_MSC_VER >= 1200)
# pragma once
#endif // defined(_MSC_VER) && (_MSC_VER >= 1200)

#include "RCF/external/asio/asio/detail/config.hpp"
#include "RCF/external/asio/asio/detail/resolver_service_base.hpp"

#include "RCF/external/asio/asio/detail/push_options.hpp"

namespace asio {
namespace detail {

class resolver_service_base::work_io_service_runner
{
public:
  work_io_service_runner(asio::io_service& io_service)
    : io_service_(io_service) {}
  void operator()() { io_service_.run(); }
private:
  asio::io_service& io_service_;
};

resolver_service_base::resolver_service_base(
    asio::io_service& io_service)
  : io_service_impl_(asio::use_service<io_service_impl>(io_service)),
    work_io_service_(new asio::io_service),
    work_io_service_impl_(asio::use_service<
        io_service_impl>(*work_io_service_)),
    work_(new asio::io_service::work(*work_io_service_)),
    work_thread_(0)
{
}

resolver_service_base::~resolver_service_base()
{
  shutdown_service();
}

void resolver_service_base::shutdown_service()
{
  work_.reset();
  if (work_io_service_)
  {
    work_io_service_->stop();
    if (work_thread_)
    {
      work_thread_->join();
      work_thread_.reset();
    }
    work_io_service_.reset();
  }
}

void resolver_service_base::construct(
    resolver_service_base::implementation_type& impl)
{
  impl.reset(static_cast<void*>(0), socket_ops::noop_deleter());
}

void resolver_service_base::destroy(
    resolver_service_base::implementation_type&)
{
}

void resolver_service_base::cancel(
    resolver_service_base::implementation_type& impl)
{
  impl.reset(static_cast<void*>(0), socket_ops::noop_deleter());
}

void resolver_service_base::start_resolve_op(operation* op)
{
  start_work_thread();
  io_service_impl_.work_started();
  work_io_service_impl_.post_immediate_completion(op);
}

void resolver_service_base::start_work_thread()
{
  asio::detail::mutex::scoped_lock lock(mutex_);
  if (!work_thread_)
  {
    work_thread_.reset(new asio::detail::thread(
          work_io_service_runner(*work_io_service_)));
  }
}

} // namespace detail
} // namespace asio

#include "RCF/external/asio/asio/detail/pop_options.hpp"

#endif // ASIO_DETAIL_IMPL_RESOLVER_SERVICE_BASE_IPP
