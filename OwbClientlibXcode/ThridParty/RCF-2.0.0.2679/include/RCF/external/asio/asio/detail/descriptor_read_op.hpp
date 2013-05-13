//
// detail/descriptor_read_op.hpp
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
// Copyright (c) 2003-2011 Christopher M. Kohlhoff (chris at kohlhoff dot com)
//
// Distributed under the Boost Software License, Version 1.0. (See accompanying
// file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
//

#ifndef ASIO_DETAIL_DESCRIPTOR_READ_OP_HPP
#define ASIO_DETAIL_DESCRIPTOR_READ_OP_HPP

#if defined(_MSC_VER) && (_MSC_VER >= 1200)
# pragma once
#endif // defined(_MSC_VER) && (_MSC_VER >= 1200)

#include "RCF/external/asio/asio/detail/config.hpp"

#if !defined(BOOST_WINDOWS) && !defined(__CYGWIN__)

#include <boost/utility/addressof.hpp>
#include "RCF/external/asio/asio/detail/bind_handler.hpp"
#include "RCF/external/asio/asio/detail/buffer_sequence_adapter.hpp"
#include "RCF/external/asio/asio/detail/descriptor_ops.hpp"
#include "RCF/external/asio/asio/detail/fenced_block.hpp"
#include "RCF/external/asio/asio/detail/reactor_op.hpp"

#include "RCF/external/asio/asio/detail/push_options.hpp"

namespace asio {
namespace detail {

template <typename MutableBufferSequence>
class descriptor_read_op_base : public reactor_op
{
public:
  descriptor_read_op_base(int descriptor,
      const MutableBufferSequence& buffers, func_type complete_func)
    : reactor_op(&descriptor_read_op_base::do_perform, complete_func),
      descriptor_(descriptor),
      buffers_(buffers)
  {
  }

  static bool do_perform(reactor_op* base)
  {
    descriptor_read_op_base* o(static_cast<descriptor_read_op_base*>(base));

    buffer_sequence_adapter<asio::mutable_buffer,
        MutableBufferSequence> bufs(o->buffers_);

    return descriptor_ops::non_blocking_read(o->descriptor_,
        bufs.buffers(), bufs.count(), o->ec_, o->bytes_transferred_);
  }

private:
  int descriptor_;
  MutableBufferSequence buffers_;
};

template <typename MutableBufferSequence, typename Handler>
class descriptor_read_op
  : public descriptor_read_op_base<MutableBufferSequence>
{
public:
  ASIO_DEFINE_HANDLER_PTR(descriptor_read_op);

  descriptor_read_op(int descriptor,
      const MutableBufferSequence& buffers, Handler handler)
    : descriptor_read_op_base<MutableBufferSequence>(
        descriptor, buffers, &descriptor_read_op::do_complete),
      handler_(handler)
  {
  }

  static void do_complete(io_service_impl* owner, operation* base,
      asio::error_code /*ec*/, std::size_t /*bytes_transferred*/)
  {
    // Take ownership of the handler object.
    descriptor_read_op* o(static_cast<descriptor_read_op*>(base));
    ptr p = { boost::addressof(o->handler_), o, o };

    // Make a copy of the handler so that the memory can be deallocated before
    // the upcall is made. Even if we're not about to make an upcall, a
    // sub-object of the handler may be the true owner of the memory associated
    // with the handler. Consequently, a local copy of the handler is required
    // to ensure that any owning sub-object remains valid until after we have
    // deallocated the memory here.
    detail::binder2<Handler, asio::error_code, std::size_t>
      handler(o->handler_, o->ec_, o->bytes_transferred_);
    p.h = boost::addressof(handler.handler_);
    p.reset();

    // Make the upcall if required.
    if (owner)
    {
      asio::detail::fenced_block b;
      asio_handler_invoke_helpers::invoke(handler, handler.handler_);
    }
  }

private:
  Handler handler_;
};

} // namespace detail
} // namespace asio

#include "RCF/external/asio/asio/detail/pop_options.hpp"

#endif // !defined(BOOST_WINDOWS) && !defined(__CYGWIN__)

#endif // ASIO_DETAIL_DESCRIPTOR_READ_OP_HPP
